class ExampleFile
  attr_accessor :path
  attr_accessor :specs
  attr_accessor :mtime
  
  def initialize(opts = {})
    @path = opts[:path] if opts[:path]
    @specs = []
    @mtime = Time.now
  end
  
  def add_spec(spec)    
    @mtime = Time.now
    spec.untaint
    if @tainting_required
      @tainting_required = false
      taint_all_specs
    end
    
    spec.file_object = self
    add_or_replace_spec(spec)
  end

  def add_or_replace_spec(spec)
    old_specs = @specs.select { |s| s.to_s == spec.to_s }
    if old_specs.empty?
      @specs << spec
    else
      @specs[@specs.index(old_specs.first)] = spec
    end
  end
  
  def sorted_specs
    sorted_specs = []
    sorted_specs += @specs.select { |s| s.state && s.state == :failed }
    sorted_specs += @specs.select { |s| s.state && s.state == :pending }
    sorted_specs += @specs.select { |s| !s.state || s.state == :passed }
    sorted_specs
  end
  
  def has_spec?(spec)
    !@specs.select { |s| s.to_s == spec.to_s }.empty?
  end
  
  def tainting_required!
    @tainting_required = true
  end  
  
  def taint_all_specs
    @specs.each { |s| s.taint }
  end
  
  def remove_tainted_specs
    @specs.collect { |spec| @specs.delete(spec) if spec.tainted? }.compact
  end
  
  def spec_count(state = :failed)
    @specs.select { |s| s.state == state }.size
  end
  
  def suicide?
    !File.exist?(self.path)
  end
  
  def name
    name = File.basename(@path).gsub(/(?:^|_)(.)/) { $1.upcase }
    name.slice!(/Spec\.rb/)
    name
  end
  
  def failed?
    spec_count(:failed) != 0
  end
  
  def pending?
    spec_count(:pending) != 0
  end

  def passed?
    spec_count(:passed) != 0
  end
end