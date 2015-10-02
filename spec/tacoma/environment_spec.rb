# Copyright (c) The Cocktail Experience S.L. (2015)
require 'spec_helper'

describe Tacoma::Environment do
  describe '#new(name)' do
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

    it 'should fail if the environment is not a key in the .tacoma.yml file' do
      Tacoma.stub(:yaml, empty_yaml) do
        lambda do
          Tacoma::Environment.new('big_project')
        end.must_raise ArgumentError
      end
    end

    it 'should create an instance with the values for the key called "name"' do
      Tacoma.stub(:yaml, valid_yaml) do
        env = Tacoma::Environment.new(project_name)
        _(env.aws_identity_file).must_equal project_conf['aws_identity_file']
      end
    end 
  end
end
