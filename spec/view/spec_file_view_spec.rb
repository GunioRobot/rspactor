require File.dirname(__FILE__) + '/../spec_helper'
require 'html_view'
require 'spec_file_view'
require 'spec_file'
require 'converter'

describe SpecFileView do
  before(:each) do
    @mock_view = mock('WebView')    
    @mock_frame = mock('Frame')
    @mock_document = mock('Document')
    @mock_element = mock('Element')
    @mock_element.stub!(:setInnerHTML)
    @mock_document.stub!(:getElementById).and_return(@mock_element)
    @mock_frame.stub!(:DOMDocument).and_return(@mock_document)
    @mock_view.stub!(:mainFrame).and_return(@mock_frame)
    @mock_spec_object = mock('SpecObject', :state => :passed, :message => 'test')
    @spec_file_view = SpecFileView.new(@mock_view, 1)
    @spec_file = SpecFile.new(:full_path => '/path/to/test.rb', :specs => [@mock_spec_object])
    $spec_list = mock('SpecList')
    $spec_list.stub!(:files).and_return(['test'])
    Converter.stub!(:source_to_html)
  end
  
  it 'should initialize with webview and file index' do
    @spec_file_view.web_view.should eql(@mock_view)
    @spec_file_view.file_index.should eql(1)
  end
  
  it 'should set the view' do
    $spec_list.should_receive(:file_by_index).and_return(@spec_file)
    @mock_spec_object.stub!(:state).and_return(:failed)
    @mock_spec_object.should_receive(:backtrace).and_return('')
    @spec_file_view.should_receive(:fold_button).and_return('<img />')
    @spec_file_view.should_receive(:setInnerHTML).with('title', /test.rb/)
    @spec_file_view.should_receive(:setInnerHTML).with('subtitle', /path\/to/)
    @spec_file_view.should_receive(:setInnerHTML)
    @spec_file_view.update
  end
  
  it 'should set the folding button by state' do
    @mock_spec_object.stub!(:state).and_return(:passed)
    @spec_file_view.fold_button(@mock_spec_object).should include('+')
    @mock_spec_object.stub!(:state).and_return(:pending)
    @spec_file_view.fold_button(@mock_spec_object).should include('-')
  end
  
  it 'should format a specs backtrace' do
    @mock_spec_object.should_receive(:backtrace).and_return(['/path/to/file.rb'])
    @spec_file_view.formatted_backtrace(@mock_spec_object).should eql('<li>/path/to/file.rb</li>')
  end
  
  it 'should not show backtraces for passing specs' do
    $spec_list.stub!(:file_by_index).and_return(@spec_file)
    @mock_spec_object.should_not_receive(:backtrace).and_return('')
    @spec_file_view.update
  end
end