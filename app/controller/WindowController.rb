class WindowController < OSX::NSWindowController
  include OSX
  include Callback
  
  attr_accessor :all_spec_table, :failed_spec_table, :pending_spec_table, :preferences_visible, :defaults

  ib_outlet :specPath, :detailView, :specRunButton, :specRunningIndicator, :viewDivider
  
  ib_action :runSpecs
  ib_action :showPreferences
  
  
  def init
    $LOG.debug "RUN: #{ENV['RSPACTOR_RUN_PATH']}"
    @growl = Growl::Notifier.alloc.initWithDelegate(self)
    @growl.start(:RSpactor, [MESSAGE_KIND, CLICKED_KIND])
    @defaults = NSUserDefaults.standardUserDefaults
    super_init    
  end
    
  def awakeFromNib
    NSApp.delegate = self
    initAndSetAutomaticPositionAndSizeStoring
    
    @all_spec_table = AllSpecTable.alloc.init(self)    
    @failed_spec_table = FailedSpecTable.alloc.init(self)    
    @pending_spec_table = PendingSpecTable.alloc.init(self)
    setCallbacks

    if !ENV['RSPACTOR_RUN_PATH'].nil?
      @specPath.stringValue = ENV['RSPACTOR_RUN_PATH']
      runSpecs(nil)
    else
      @specPath.stringValue = @defaults.stringForKey("last_spec_path") || ''
      $coreInterop.start_listen(@specPath.stringValue)    
    end
    # initStatusBar
  end
  
  def runSpecs(sender)
    path = @specPath.stringValue
    return unless File.exist? path
    start_spec_run(path)
  end  
  
  def start_spec_run(path)
    @specRunningIndicator.setIndeterminate(true)    
    @specRunningIndicator.startAnimation(self)      
    @specRunButton.Enabled = false
    $failed_specs.clear
    $coreInterop.run_specs_in_path(path)
  end
  
  def stop_spec_run
    @specRunButton.Enabled = true
    @specRunningIndicator.stopAnimation(self)     
    $coreInterop.start_listen(@specPath.stringValue)    
  end
  
  def showPreferences(sender)
    $pref_controller.show
  end
  
  def initStatusBar
    system_menu = NSMenu.new
    system_menu_item = NSMenuItem.new
    system_menu_item.title = "Halloasd"
    system_menu.addItem(system_menu_item)
    menu_bar = NSStatusBar.systemStatusBar()
    @system_icon = menu_bar.statusItemWithLength(NSVariableStatusItemLength)
    @system_icon.setHighlightMode(true)
    @system_icon.setMenu(system_menu)
    setSystemMenuIcon
  end
  
  def setSystemMenuIcon(type = :ok)
    return  # cause system icon is currently disabled
    file = fileFromType(type)
    @system_icon.setImage(imageFromFileName(file))
  end
  
  def growlImage(type = :ok)
    file = fileFromType(type)
    imageFromFileName(file, 128)
  end
  
  
  # Play the delegate song
  
  # Listen for changes in Path-Text-Field and change textcolor to red if the path is invalid
  def controlTextDidChange(notification)
    if File.exist? notification.object.stringValue
      @defaults.setObject_forKey(notification.object.stringValue, 'last_spec_path')          
      notification.object.textColor = NSColor.blackColor
    else
      notification.object.textColor = NSColor.redColor
    end
  end
  
  def applicationWillTerminate(notification)
    $coreInterop.stop_listen
  end
  
  def growl_onClicked(sender, context)
    External.open_editor_with_file_from_ext_link context
  end
  
    
  private
  
  def fileFromType(type = :ok)
    case type
    when :ok
      'add'
    when :pass
      'accept'
    when :failure
      'remove'
    when :error
      'warning'
    end
  end
  
  def imageFromFileName(file_name, size = 16)
    NSImage.new.initByReferencingFile(File.join(File.dirname(__FILE__), '../../', "#{file_name}_#{size}.png"))
  end
  
  def initAndSetAutomaticPositionAndSizeStoring
    shouldCascadeWindows = false
    self.window.frameUsingName = 'rspactor_main_window'
    self.window.setFrameAutosaveName('rspactor_main_window')
    @viewDivider.setAutosaveName('last_divider_position')    
  end
end
