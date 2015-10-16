# Copyright (c) The Cocktail Experience S.L. (2015)
require 'spec_helper'
include Tacoma::Specs

describe Tacoma do
  describe 'CHANGELOG' do
    let(:first_line) { File.open('CHANGELOG') {|f| f.readline } }

    it 'explains at least the improvements done in new minor versions' do
      mayor_minor(first_line).must_equal mayor_minor(Tacoma::VERSION)
    end
  end

  describe 'class methods' do
    before do
      @real_home = ENV['HOME']
      ENV['HOME'] = Tacoma::SPECS_HOME # ./spec/fixtures/home
    end
  
    after do
      ENV['HOME'] = @real_home
    end 

    describe '.installed?' do
      it 'returns true if ~/.tacoma.yml exists' do
        _(Tacoma.installed?).must_equal true
      end 

      it 'returns false if ~/.tacoma.yml does NOT exist' do
        FileUtils.rm_rf Tacoma::SPECS_TMP
        ENV['HOME'] = Tacoma::SPECS_TMP
        _(Tacoma.installed?).must_equal false
      end 

      it 'ensures that ~/.tacoma/templates is also there' do
        skip
      end
    end
  end
end
