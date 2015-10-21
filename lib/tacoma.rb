require 'yaml'

require_relative './tacoma/command'
require_relative './tacoma/version'

module Tacoma
  TOOLS = {
    fog: '.fog',
    boto: '.boto',
    s3cfg: '.s3cfg',
    route53: '.route53',
    aws_credentials: '.aws/credentials'
  }

  module_function
  # NOTE: removes the first char (dot) for tool files
  def template_file(tool)
    tool ? TOOLS[tool][1..-1] : 'tacoma.yml'
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
