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
  def yaml
    YAML::load_file(File.join(Dir.home, ".tacoma.yml"))
  end
end
