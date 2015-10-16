# Copyright (c) The Cocktail Experience S.L. (2015)
require 'spec_helper'

describe Tacoma::Tool do
  describe '.gem_files' do
    TOOLS = {
      fog: '.fog',
      boto: '.boto',
      s3cfg: '.s3cfg',
      route53: '.route53',
      aws_credentials: '.aws/credentials'
    }

    it 'should equals TOOLS' do
      Tacoma::Tool.gem_files.must_equal TOOLS
    end
  end

  describe '.gem_tools' do
    it 'should get them from the templates directory entries' do
      skip
    end
  end
end
