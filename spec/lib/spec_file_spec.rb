require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_file'
require 'spec_object'

describe SpecFile do
  it 'should initialize with an arbitrary number of params' do
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => ['huhu'])
    file.full_path.should eql('/home/test.rb')
    file.specs.should eql(['huhu'])
  end
  
  it 'should split the full file path into the file_name' do
    file = SpecFile.new(:full_path => '/home/test.rb')
    file.name.should eql('test.rb')
  end
  
  it 'should have a << method to add specs' do
    file = SpecFile.new(:full_path => '/home/test.rb')
    lambda do
      file << SpecObject.new
    end.should change(file, :spec_count)
  end
  
  it 'should replace a spec file if it already exists in the collection' do
    so1 = SpecObject.new(:name => 'test', :state => :passed)
    so2 = SpecObject.new(:name => 'test', :state => :failed)
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so1])
    lambda do
      file << so2
    end.should_not change(file, :spec_count)
    file.specs.first.state.should eql(:failed)
  end
  
  it 'should have a spec_count' do
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => ['1', '2', '3'])
    file.spec_count.should eql(3)
  end
  
  it 'should know if it contains a spec' do
    so = SpecObject.new
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so])
    file.contains_spec?(so).should be_true    
  end
  
  it 'should return if it contains failed specs' do
    so = SpecObject.new(:state => :failed)
    file = SpecFile.new(:full_path => '/home/test.rb', :specs => [so])
    file.failed?.should be_true
  end
end