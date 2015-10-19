require 'yaml'

require_relative './tacoma/version'
require_relative './tacoma/command'
require_relative './tacoma/tool'

module Tacoma
  module_function
  def installed?
    File.exist?(File.join(Dir.home, '.tacoma.yml'))
  end

  # NOTE: removes the first char (dot) for tool files
  def template_file(tool)
    tool ? Tool.gem_files[tool][1..-1] : 'tacoma.yml'
  end

  def gem_template_file(tool = nil)
    gem_templates_dir + template_file(tool)
  end

  def home_template_file(tool = nil)
    home_templates_dir + template_file(tool)
  end

  def gem_templates_dir
    File.dirname(__FILE__) + '/templates/'
  end

  def home_templates_dir
    Dir.home + '/.tacoma/templates/'
  end

  def yaml
    YAML::load_file(File.join(Dir.home, ".tacoma.yml"))
  end

  # Assume there's a ~/.aws/credentials file with a valid format.
  def credentials_key_id
    current_filename = File.join(Dir.home, ".aws/credentials")
    File.open(current_filename).each do |line|
      return line[20..-2] if /aws_access_key_id/ =~ line
    end
    nil
  end
end
