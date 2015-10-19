# Copyright (c) The Cocktail Experience S.L. (2015)
require 'spec_helper'

describe Tacoma::Environment do
  before do
    @real_home = ENV['HOME']
    ENV['HOME'] = Tacoma::SPECS_HOME # ./spec/fixtures/home
  end

  after do
    ENV['HOME'] = @real_home
  end

  let(:first_project) { 'first_project' }
  let(:first_project_key) { 'FirstProjectAccessKeyId' }
  let(:current_project) { 'second_project' }

  describe '.current' do
    it 'is defined by the aws_access_key_id value in ~/.aws/credentials' do
      # and our fake home in spec/fixtures have that defined:
      _(Tacoma::Environment.current).must_equal current_project
    end

    it 'gives priority to the AWS_ACCESS_KEY_ID env. variable' do
      ClimateControl.modify({ AWS_ACCESS_KEY_ID: first_project_key }) do
        _(Tacoma::Environment.current).must_equal first_project
      end
    end 
  end

  describe '#new([name])' do
    let(:empty_yaml) { {} }
    let(:valid_yaml) {
      {
        'project' => {
          'aws_identity_file'     => '/path/to/project.pem',
          'aws_secret_access_key' => 'SECRET-ACCESS-KEY',
          'aws_access_key_id'     => 'ACCESS-KEY-ID',
          'repo'                  => '/path/to/repo'
        }
      }  
    }
    let(:project_name) { valid_yaml.keys.first }
    let(:project_conf) { valid_yaml[project_name] }

    let(:project_REPO) { '/ENV/path/to/repo' }

    it 'should fail if the environment is not a key in the .tacoma.yml file' do
      Tacoma.stub(:yaml, empty_yaml) do
        lambda do
          Tacoma::Environment.new('big_project')
        end.must_raise ArgumentError
      end
    end

    it 'creates an instance with the values for current environment if no name received' do
        env = Tacoma::Environment.new
        _(env.name).must_equal current_project
        _(env.aws_access_key_id).must_equal 'SecondProjectAccessKeyId'
    end 

    it 'should create an instance with the values for the key called "name"' do
      Tacoma.stub(:yaml, valid_yaml) do
        env = Tacoma::Environment.new(project_name)
        _(env.name).must_equal project_name
        _(env.aws_identity_file).must_equal project_conf['aws_identity_file']
      end
    end 

    it 'should give priority to any conf. value available as environment variable' do
      Tacoma.stub(:yaml, valid_yaml) do
        ClimateControl.modify({ REPO: project_REPO }) do
          env = Tacoma::Environment.new(project_name)
          _(env.repo).must_equal project_REPO
        end
      end
    end 
  end
end
