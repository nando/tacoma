# Copyright (c) The Cocktail Experience S.L. (2015)
require 'yaml'

module Tacoma
  class Tool
    class << self
      def gem_files
        gem_tools.map do |key|
          [key, ".#{key}".gsub('_','/')]
        end.to_h
      end
  
      def gem_tools
        tool_names_in(Tacoma.gem_templates_dir)
      end
  
      private
  
      def tool_names_in(directory)
        names = Dir[directory + '*'].map do |name|
          name[directory.length..-1]
        end
        names.delete 'tacoma.yml'
        names.map {|name| name == 'aws' ? :aws_credentials : name.to_sym }
      end
    end
  end
end
