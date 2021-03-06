require 'backup/actor'
require 'backup/rotator'

module Backup
  # Represents a specific Backup configuration. A Configuration instance
  # may be used to load multiple recipe files, define and describe tasks,
  # define roles, create an actor, and set configuration variables.
  class Configuration
    # The actor created for this configuration instance.
    attr_reader :actor

    # The logger instance defined for this configuration.
    attr_reader :logger

    # The load paths used for locating recipe files.
    attr_reader :load_paths

    # The hash of variables currently known by the configuration
    attr_reader :variables

    def initialize(actor_class=Actor) #:nodoc:
      @actor = actor_class.new(self)
      #@logger = Logger.new
      @load_paths = [".", File.join(File.dirname(__FILE__), "recipes")]
      @variables = {}
    end

    # Set a variable to the given value.
    def set(variable, value=nil, &block)
      # if the variable is uppercase, then we add it as a constant to the
      # actor. This is to allow uppercase "variables" to be set and referenced
      # in recipes.
      if variable.to_s[0].between?(?A, ?Z)
        klass = @actor.metaclass
        klass.send(:remove_const, variable) if klass.const_defined?(variable)
        klass.const_set(variable, value)
      end

      value = block if value.nil? && block_given?
      @variables[variable] = value
    end

    alias :[]= :set

    def [](variable)
      # TODO have it raise if it doesn exist
      @variables[variable]
    end

    # Require another file. This is identical to the standard require method,
    # with the exception that it sets the reciever as the "current" configuration
    # so that third-party task bundles can include themselves relative to
    # that configuration.
    def require(*args) #:nodoc:
      original, Backup.configuration = Backup.configuration, self
      super
    ensure
      # restore the original, so that require's can be nested
      Backup.configuration = original
    end

    # Disclaimer: This method written by Jamis Buck. Taken directly from his
    # excellent code Capistrano.
    #
    # Load a configuration file or string into this configuration.
    #
    # Usage:
    #
    #   load("recipe"):
    #     Look for and load the contents of 'recipe.rb' into this
    #     configuration.
    #
    #   load(:file => "recipe"):
    #     same as above
    #
    #   load(:string => "set :scm, :subversion"):
    #     Load the given string as a configuration specification.
    #
    #   load { ... }
    #     Load the block in the context of the configuration.
    def load(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args.each { |arg| load options.merge(:file => arg) }
      return unless args.empty?

      if block
        raise "loading a block requires 0 parameters" unless args.empty?
        load(options.merge(:proc => block))

      elsif options[:file]
        file = options[:file]
        unless file[0] == ?/
          load_paths.each do |path|
            if File.file?(File.join(path, file))
              file = File.join(path, file)
              break
            elsif File.file?(File.join(path, file) + ".rb")
              file = File.join(path, file + ".rb")
              break
            end
          end
        end
        load :string => File.read(file), :name => options[:name] || file

      elsif options[:string]
        #logger.trace "loading configuration #{options[:name] || "<eval>"}"
        instance_eval(options[:string], options[:name] || "<eval>")

      elsif options[:proc]
        #logger.trace "loading configuration #{options[:proc].inspect}"
        instance_eval(&options[:proc])

      else
        raise ArgumentError, "don't know how to load #{options.inspect}"
      end
    end

    # Describe the next task to be defined. The given text will be attached to
    # the next task that is defined and used as its description.
    def desc(text)
      @next_description = text
    end

    # Define a new task. If a description is active (see #desc), it is added to
    # the options under the <tt>:desc</tt> key. This method ultimately
    # delegates to Actor#define_task.
    def action(name, options={}, &block)
      # raise ArgumentError, "expected a block or method" unless block or options[:method]  # ?? 
      if @next_description
        options = options.merge(:desc => @next_description)
        @next_description = nil
      end
      actor.define_action(name, options, &block)
    end

  end
end
