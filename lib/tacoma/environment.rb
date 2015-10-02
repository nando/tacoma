# Copyright (c) The Cocktail Experience S.L. (2015)
module Tacoma
  class Environment
    attr_reader :conf

    def initialize(name)
      if (@conf = Tacoma.yaml[name])
        @name = name
      else
        fail ArgumentError, "Cannot find #{name} key, check your YAML config file"
      end
    end

    def aws_identity_file
      @conf['aws_identity_file']
    end

    def aws_secret_access_key
      @conf['aws_secret_access_key']
    end

    def aws_access_key_id
      @conf['aws_access_key_id']
    end

    def repo
      @conf['repo']
    end

    class << self
      # Assume there is a ~/.aws/credentials file with a valid format
      def current
        current_filename = File.join(Dir.home, ".aws/credentials")
        File.open(current_filename).each do |line|
          if /aws_access_key_id/ =~ line
            current_access_key_id = line[20..-2] # beware the CRLF
            yaml = Tacoma.yaml
            for key in yaml.keys
              if yaml[key]['aws_access_key_id'] == current_access_key_id
                return "#{key}"
              end
            end
          end
        end  
        nil
      end
    end
  end
end
