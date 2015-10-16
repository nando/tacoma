require 'yaml'

require_relative './tacoma/command'
require_relative './tacoma/version'

module Tacoma
  class Tool
    def self.files
      TOOLS # pre-removal commit
    end

    private

    TOOLS = {
      fog: '.fog',
      boto: '.boto',
      s3cfg: '.s3cfg',
      route53: '.route53',
      aws_credentials: '.aws/credentials'
    }
  end

  module_function
  def installed?
    File.exist?(File.join(Dir.home, '.tacoma.yml'))
  end

  # NOTE: removes the first char (dot) for tool files
  def template_file(tool)
    tool ? Tool.files[tool][1..-1] : 'tacoma.yml'
  end

  def gem_template_file(tool = nil)
    File.dirname(__FILE__) + '/templates/' + template_file(tool)
  end

  def home_template_file(tool = nil)
    Dir.home + '/.tacoma/templates/' + template_file(tool)
  end

  def yaml
    YAML::load_file(File.join(Dir.home, ".tacoma.yml"))
  end
end
