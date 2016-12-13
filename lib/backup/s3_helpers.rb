require 'yaml'

module Backup
  class S3Actor

    attr_accessor :rotation

    attr_reader :config

    def initialize(config)
      @config       = config
      @rotation_key = config[:rotation_object_key] || 'backup_rotation_index.yml'

      s3_config = {
        :access_key_id => config[:aws_access] || ENV['AMAZON_ACCESS_KEY_ID'],
        :secret_access_key => config[:aws_secret] || ENV['AMAZON_SECRET_ACCESS_KEY'],
        :s3_server_side_encryption => config[:s3_server_side_encryption] ? :aes256 : nil,
      }

      @bucket = AWS::S3.new(s3_config).buckets[config[:aws_bucket]] # bucket needs to exist
    end

    def rotation
      s3_key = @bucket.objects[@rotation_key]
      YAML::load(s3_key.read) if s3_key.exists?
    end

    def rotation=(index)
      s3_key = @bucket.objects[@rotation_key]
      s3_key.write(index.to_yaml)
      index
    end

    # Send a file to s3
    def put(last_result)
      object_key = Rotator.timestamped_prefix(last_result)
      puts "put: #{object_key}"

      `AWS_ACCESS_KEY_ID="#{config[:aws_access]}" AWS_SECRET_ACCESS_KEY="#{config[:aws_secret]}" /usr/local/bin/aws s3 cp #{last_result} s3://#{config[:aws_bucket]}/#{object_key} --sse`

      object_key
    end

    # Remove a file from s3
    def delete(object_key)
      puts "delete: #{object_key}"
      @bucket.objects[object_key].delete
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
end
