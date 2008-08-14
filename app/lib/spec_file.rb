class SpecFile
  attr_accessor :full_path, :name
  attr_accessor :specs
  
  def initialize(opts = {})
    @specs = []
    opts.each { |key, value| self.send("#{key.to_s}=".intern, value) } rescue true
  end
  
  def prepare_next_run
    @tainting_required = true
  end
  
  def name    
    File.basename(@full_path) if @full_path
  end
  
  def <<(spec)
    if @tainting_required
      @tainting_required = false
      taint_all_specs
    end
    
    old_spec = @specs.select {|s| s.to_s == spec.to_s}.first
    if old_spec
      @specs[@specs.index(old_spec)] = spec
    else
      @specs << spec
    end
  end
  
  def specs
    sorted_specs = []
    sorted_specs += @specs.select { |s| s.state && s.state == :failed }
    sorted_specs += @specs.select { |s| s.state && s.state == :pending }
    sorted_specs += @specs.select { |s| !s.state || s.state == :passed }
    sorted_specs
  end
  
  def spec_count
    @specs.size
  end
  
  # TODO: Obsolete?
  def contains_spec?(spec)
    !@specs.select { |s| s.to_s == spec.to_s }.empty?
  end
  
  def failed?
    !@specs.select { |s| s.state == :failed }.empty?
  end
  
  def pending?
    return false if failed?
    !@specs.select { |s| s.state == :pending }.empty?
  end
  
  def taint_all_specs
    @specs.each { |s| s.taint }
  end  
  
  def remove_tainted_specs
    @specs.collect { |spec| @specs.delete(spec) if spec.tainted? }.compact
  end
end