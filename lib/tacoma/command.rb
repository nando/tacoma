# Copyright (c) The Cocktail Experience S.L. (2015)
require 'thor'
require 'pathname'

require_relative 'environment'

module Tacoma

  class Command < Thor

    include Thor::Actions

    desc "list", "Lists all known AWS environments"
    def list
      Tacoma.yaml.keys.each do |key|
        puts key
      end
    end

    desc "version", "Displays current tacoma version"
    def version
      puts "tacoma, version #{Tacoma::VERSION}"
      puts "Configuration templates available for:"
      Tool.gem_files.each do |tool, config_path|
        puts "   #{tool} => '~/#{config_path}'"
      end
    end

    desc "current", "Displays current loaded tacoma environment"
    long_desc <<-LONG_DESC
      Displays current loaded tacoma environment assuming the AWS credentials
      are defined in one of the following:
       * as AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY env. variables, otherwise 
       * in the ~/.aws/credentials file with a valid format.
    LONG_DESC
    def current
      puts Environment.current
      return true
    end
    
    desc "switch ENVIRONMENT", "Prepares AWS config files for the providers. --with-exports will output environment variables"
    option :'with-exports', type: :boolean
    def switch(environment)
      if @env = Environment.new(environment)
        # set configurations for tools
        Tool.gem_files.each do |tool, config_path|
          template_path = Pathname.new(Tacoma.home_template_file(tool)).realpath
          file_path = File.join(Dir.home, config_path)
          template template_path, file_path, :force => true
        end
        
        system("ssh-add #{@env.aws_identity_file}")
        if options[:'with-exports']
          puts "export AWS_SECRET_ACCESS_KEY=#{@env.aws_secret_access_key}"
          puts "export AWS_SECRET_KEY=#{@env.aws_secret_access_key}"
          puts "export AWS_ACCESS_KEY=#{@env.aws_access_key_id}"
          puts "export AWS_ACCESS_KEY_ID=#{@env.aws_access_key_id}"
        end
        return true
      else
        return false
      end
    end

    desc "cd ENVIRONMENT", "Change directory to the project path"
    def cd(environment)
      if switch(environment)
        Dir.chdir `echo #{@env.repo}`.strip
        puts "Welcome to the tacoma shell"
        shell = ENV['SHELL'].split('/').last
        options =
          case shell
          when 'zsh'
            ''
          else
            '--login'
          end
        system("#{shell} #{options}")
        Process.kill(:SIGQUIT, Process.getpgid(Process.ppid))
      end
    end

    desc "install", "Create a sample ~/.tacoma.yml file"
    def install
      if (File.exists?(File.join(Dir.home, ".tacoma.yml")))
        puts "File ~/.tacoma.yml already present, won't overwrite"
      else
        template_path = Pathname.new(Tacoma.gem_template_file).realpath
        new_path = File.join(Dir.home, ".tacoma.yml")
        template template_path, new_path
      end

      Tacoma::Tool.gem_files.each do |tool, config_file|
        template_path = Pathname.new(Tacoma.gem_template_file(tool)).realpath
        home_template = Tacoma.home_template_file(tool)
        copy_file template_path, home_template
      end
    end

    desc 'yaml', 'Shows values in ~/.tacoma.yml for the current environment'
    long_desc <<-LONG_DESC
      Show the ~/.tacoma.yml values of the environment which aws_access_key_id
      is specified by the AWS_ACCESS_KEY_ID env. variable or, if not defined,
      the value of the aws_access_key_id key in our ~/.aws/credentials file.
    LONG_DESC
    def yaml
      Tacoma::Environment.new.conf.each do |key, value|
        puts key + ":\t" + value
      end
    end

    def self.source_root
      File.dirname(__FILE__)
    end

  end

end
