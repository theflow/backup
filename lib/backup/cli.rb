require 'optparse'
require 'backup'
require 'yaml'

module Backup
  # The CLI class encapsulates the behavior of backup when it is invoked
  # as a command-line utility.
  class CLI
    # Invoke capistrano using the ARGV array as the option parameters. 
    def self.execute!
      new.execute!
    end

    # The array of (unparsed) command-line options
    attr_reader :args

    # The hash of (parsed) command-line options
    attr_reader :options
 
    # Docs for creating a new instance go here
    def initialize(args = ARGV)
      @args = args
      @options = { :recipes => [], :actions  => [], 
                      :vars => {}, # :pre_vars => {}, 
                    :global => nil  }

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options]"

        opts.separator ""
        opts.separator "Recipe Options -----------------------"
        opts.separator ""

        opts.on("-r", "--recipe RECIPE ",
          "A recipe file to load. Multiple recipes is DEPRECATED and not fully functional."
        ) { |value| @options[:recipes] << value }

        opts.on("-s", "--set NAME=VALUE",
          "Specify a variable and it's value to set. This",
          "will be set after loading all recipe files."
        ) do |pair|
          name, value = pair.split(/=/, 2)
          @options[:vars][name.to_sym] = value
        end

        opts.on("-g", "--global RECIPE",
          "Specify a specific file to load as the global file",
          "for the recipes. By default the recipes load the",
          "file +global.rb+ in the same directory." 
        ) { |value| @options[:recipes] << value }

        opts.on("-q", "--quiet",
              "suppresses much of the output of backup, except",
              "for error messages") { verbose(false) }

        if args.empty?
          puts opts
          exit
        else
          opts.parse!(args)
        end

        check_options!

      end

    end

    # Begin running Backup based on the configured options.
    def execute!
      #if !@options[:recipes].empty? # put backk
        execute_recipes!
      # elsif @options[:apply_to]
      #  execute_apply_to!
      #end
    end


    private
      def check_options!
        # perform a sanity check
      end

      # Load the recipes specified by the options, and execute the actions
      # specified.
      def execute_recipes!
        config = Backup::Configuration.new
        #config.logger.level = options[:verbose]
        #options[:pre_vars].each { |name, value| config.set(name, value) }
        options[:vars].each { |name, value| config.set(name, value) }

        # load the standard recipe definition
        config.load "standard"
        options[:recipes].each do |recipe| 
          global = options[:global] || File.dirname(recipe) + "/global.rb"
          config.load global if File.exists? global    # cache this?
        end

        options[:recipes].each_with_index do |recipe,i|
          config.load(recipe) 
          $state = setup_saved_state(recipe, config) 
          warn "DEPRICATED: Using multiple recipes with one command is deprecated for the time being. Just run a different command if you want to do two recipes at the same time" if i > 0

        end

        #options[:vars].each { |name, value| config.set(name, value) }

        actor = config.actor
        actor.start_process! # eventually make more options, like the ability
                             # to run each action individually
        #options[:actions].each { |action| actor.send action }
      end

      
      # Setup the persistant state using madeline
      def setup_saved_state(recipe, config)
        if defined? ::NO_NUMERIC_ROTATION
            if :numeric == config[:rotation_mode]
              puts "Missing Gem: :numeric :rotation mode is not valid unless you have madeleine installed. try: 'gem install madeleine'"
              exit 1
            end
            return nil
        end

        saved_state_folder = config[:saved_state_folder] || File.join(config[:backup_path], ".backupgem_#{File.basename(recipe)}_state")

        state = SnapshotMadeleine.new(saved_state_folder, YAML) do
          StateRecorder.new
        end
        state.system.saved_state_folder = saved_state_folder
        state
      end

  end    
end

at_exit { 

  if !defined?(::NO_NUMERIC_ROTATION) && defined?($state)
    $state.take_snapshot
    $state.system.cleanup_snapshots
  end
}

