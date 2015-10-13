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
      TOOLS.each do |tool, config_path|
        puts "   #{tool} => '~/#{config_path}'"
      end
    end

    desc "current", "Displays current loaded tacoma environment"
    def current
      puts Environment.current
      return true
    end
    
    desc "switch ENVIRONMENT", "Prepares AWS config files for the providers. --with-exports will output environment variables"
    option :'with-exports', type: :boolean
    
    def switch(environment)
      if @env = Environment.new(environment)
        # set configurations for tools
        TOOLS.each do |tool, config_path|
          template_path = Pathname.new("#{self.class.source_root}/../template/#{tool}").realpath.to_s
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
        template_path=Pathname.new("#{self.class.source_root}/../template/tacoma.yml").realpath.to_s
        new_path = File.join(Dir.home, ".tacoma.yml")
        template template_path, new_path
      end
    end

    def self.source_root
      File.dirname(__FILE__)
    end

  end

end
