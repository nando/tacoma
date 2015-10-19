# Copyright (c) The Cocktail Experience S.L. (2015)
module Tacoma
  class Environment
    attr_reader :name
    attr_reader :conf

    def initialize(name=nil)
      name ||= self.class.current
      if (@conf = Tacoma.yaml[name])
        @name = name
      else
        fail ArgumentError, "Cannot find #{name} key, check your YAML config file"
      end
    end

    def aws_identity_file
      from_ENV_or_yaml 'aws_identity_file'
    end

    def aws_secret_access_key
      from_ENV_or_yaml 'aws_secret_access_key'
    end

    def aws_access_key_id
      from_ENV_or_yaml 'aws_access_key_id'
    end

    def repo
      from_ENV_or_yaml 'repo'
    end

    private

    def from_ENV_or_yaml(key)
      ENV[key.upcase] || @conf[key]
    end

    class << self
      # Assume the AWS credentials are defined in:
      #  * the AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY env. variables, or
      #  * in a ~/.aws/credentials file with a valid format.
      def current
        current_access_key_id = ENV['AWS_ACCESS_KEY_ID'] || Tacoma.credentials_key_id
        (yaml = Tacoma.yaml).keys.detect do |key|
          yaml[key]['aws_access_key_id'] == current_access_key_id
        end
      end
    end
  end
end
