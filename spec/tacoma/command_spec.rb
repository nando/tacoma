# Copyright (c) The Cocktail Experience S.L. (2015)
require 'spec_helper'
include Tacoma::Specs

describe Tacoma::Command do
  subject { Tacoma::Command.new }

  before do
    @real_home = ENV['HOME']
    ENV['HOME'] = Tacoma::SPECS_HOME # ./spec/fixtures/home
  end

  after do
    ENV['HOME'] = @real_home
  end

  describe '#install' do
    let(:output) { capture_io { subject.install }[0] }

    it 'should not overwrite ~/.tacoma.yml if we already have one' do
      output.must_include '~/.tacoma.yml already present'
    end

    it 'should create ~/.tacoma.yml using the template' do
      FileUtils.rm_rf Tacoma::SPECS_TMP
      ENV['HOME'] = Tacoma::SPECS_TMP
      output.must_match /create .+\.tacoma\.yml/
      assert File.exist?("#{ENV['HOME']}/.tacoma.yml")
    end
  end

  describe '#list' do
    let(:output) { capture_io { subject.list }[0] }

    it 'lists all AWS environments in the .tacoma.yml file' do
      output.must_equal <<-OUTPUT.gsub(/^ {8}/, '')
        first_project
        second_project
      OUTPUT
    end
  end

  describe '#switch' do
    before do
      FileUtils.rm_rf Tacoma::SPECS_TMP
      ENV['HOME'] = Tacoma::SPECS_TMP
      capture_io { subject.install }
    end

    it 'creates the config files for the specified environment' do
      output = capture_io { subject.switch 'my_first_project' }[0]

      output.must_match /(?:\s+create .+\n){#{Tacoma::TOOLS.size}}/
      # And we have in .aws/credentials my_first_project's key
      aws_credential_value('aws_access_key_id').must_equal 'YOURACCESSKEYID'
    end

    it 'overwrites the config files for the specified environment' do
      output = capture_io do
        subject.switch 'my_first_project'
        subject.switch 'my_second_project'
      end[0]
      output.must_match /(?:\s+force .+\n){#{Tacoma::TOOLS.size}}/
      aws_credential_value('aws_access_key_id').must_equal 'ANOTHERACCESSKEYID'
    end
  end

  describe 'templates' do
    before do
      FileUtils.rm_rf Tacoma::SPECS_TMP
      ENV['HOME'] = Tacoma::SPECS_TMP
      capture_io { subject.install }
    end

    let(:access_key) { 'TEMPLATES_SPEC_KEY_ID' }

    it 'use environment variables when available' do
      ClimateControl.modify({ AWS_ACCESS_KEY_ID: access_key }) do
        capture_io { subject.switch 'my_first_project' }
        aws_credential_value('aws_access_key_id').must_equal access_key
      end
    end
  end
end
