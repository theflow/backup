require 'yaml'

module Backup
  class S3Actor
    
    attr_accessor :rotation
    
    attr_reader :config
    alias_method :c, :config

    def initialize(config)
      @config       = config
      @rotation_key = c[:rotation_object_key] ||= 'backup_rotation_index.yml'
      @access_key   = c[:aws_access] ||= ENV['AMAZON_ACCESS_KEY_ID']
      @secret_key   = c[:aws_secret] ||= ENV['AMAZON_SECRET_ACCESS_KEY']
      @bucket_key   = c[:aws_bucket]
      @s3 = RightAws::S3.new(@access_key, @secret_key)
      @bucket = @s3.bucket(@bucket_key, true)
    end

    def rotation
      key = @bucket.key(@rotation_key)
      YAML::load(key.data) if key.exists?
    end

    def rotation=(index)
      @bucket.put(@rotation_key, index.to_yaml)
      index
    end

    # Send a file to s3
    def put(last_result)
      object_key = Rotator.timestamped_prefix(last_result)
      puts "put: #{object_key}"
      @bucket.put(object_key, open(last_result))
      object_key
    end

    # Remove a file from s3
    def delete(object_key)
      puts "delete: #{object_key}"
      @bucket.key(object_key).delete
    end

    # Make sure our rotation index exists and contains the hierarchy we're using.
    # Create it if it does not exist
    def verify_rotation_hierarchy_exists(hierarchy)
      index = self.rotation
      if index
        verified_index = index.merge(init_rotation_index(hierarchy)) { |m,x,y| x ||= y }
        unless (verified_index == index)
          self.rotation = verified_index
        end
      else
        self.rotation = init_rotation_index(hierarchy)
      end
    end

    # Expire old objects
    def cleanup(generation, keep)
      puts "Cleaning up #{generation} #{keep}"
      
      new_rotation = self.rotation
      keys = new_rotation[generation]
            
      diff = keys.size - keep
      
      1.upto( diff ) do
        extra_key = keys.shift
        delete extra_key
      end
            
      # store updated index
      self.rotation = new_rotation
    end

    private
    
      # Create a new index representing our backup hierarchy
      def init_rotation_index(hierarchy)
        hash = {}
        hierarchy.each do |m|
          hash[m] = Array.new
        end
        hash
      end
    
  end

  class ChunkingS3Actor < S3Actor
    DEFAULT_MAX_OBJECT_SIZE = 5368709120 # 5 * 2^30 = 5GB
    DEFAULT_CHUNK_SIZE = 4294967296 # 4 * 2^30 = 4GB

    def initialize(config)
      super
      @max_object_size = c[:max_object_size] ||= DEFAULT_MAX_OBJECT_SIZE
      @chunk_size = c[:chunk_size] ||= DEFAULT_CHUNK_SIZE
    end

    # Send a file to s3
    def put(last_result)
      object_key = Rotator.timestamped_prefix(last_result)
      puts "put: #{object_key}"
      # determine if the file is too large
      if File.stat(last_result).size > @max_object_size
        # if so, split
        split_command = "cd #{File.dirname(last_result)} && split -d -b #{@chunk_size} #{File.basename(last_result)} #{File.basename(last_result)}."
        puts "split: #{split_command}"
        system split_command
        chunks = Dir.glob("#{last_result}.*")
        # put each file in the split
        chunks.each do |chunk|
          chunk_index = chunk.sub(last_result,"")
          chunk_key = "#{object_key}#{chunk_index}"
          puts "  #{chunk_key}"
          @bucket.put(chunk_key, open(chunk))
        end
      else
        @bucket.put(object_key, open(last_result))
      end
      object_key
    end

    # Remove a file from s3
    def delete(object_key)
      puts "delete: #{object_key}"
      # determine if there are multiple objects with this key prefix
      chunks = @bucket.keys(:prefix => object_key)
      if chunks.size > 1
        # delete them all
        chunks.each do |chunk|
          puts "  #{chunk.name}"
          chunk.delete
        end
      else
        chunks.first.delete
      end
    end
  end
end
