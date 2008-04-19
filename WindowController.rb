require 'osx/cocoa'
require 'Growl'

class WindowController < OSX::NSWindowController
  include OSX
  include Callback
  
  attr_accessor :failed_spec_table, :preferences_visible

  ib_outlet :specPath, :detailView, :specRunButton, :specRunningIndicator
  ib_action :runSpecs
  ib_action :showPreferences
  ib_action :interceptPathInput
  
  def init
    @growl = Growl::Notifier.alloc.initWithDelegate(self)
    @growl.start(:RSpactor, [MESSAGE_KIND, CLICKED_KIND])    
    @pref = false
    super_init    
  end
    
  def awakeFromNib
    initAndSetAutomaticPositionAndSizeStoring
    @failed_spec_table = SpecTable.alloc.init(self)    
    $coreInterop.start_listen(@specPath.stringValue)    
    setCallbacks
    initStatusBar
  end
  
  def selectSpecUnlessSelected
    puts "Halo: #{failed_spec_table.selectedRow}"
  end
  
  def updateDetailView(content)
    @detailView.textStorage.mutableString.setString(content)
  end
  
  def interceptPathInput(sender)
    NSLog "tipppppet"
  end

  def runSpecs(sender)
    path = @specPath.stringValue
    return unless File.exist? path
    
    @specRunningIndicator.setIndeterminate(true)    
    @specRunningIndicator.startAnimation(self)      
    @specRunButton.Enabled = false
    $failed_specs.clear
    $coreInterop.run_specs_in_path(path)
    @failed_spec_table.clearSelection    
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
      notification.object.textColor = NSColor.blackColor
    else
      notification.object.textColor = NSColor.redColor
    end
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
    NSImage.new.initByReferencingFile(File.join(File.dirname(__FILE__), "#{file_name}_#{size}.png"))
  end
  
  def initAndSetAutomaticPositionAndSizeStoring
    shouldCascadeWindows = false
    self.window.frameUsingName = 'rspactor_main_window'
    self.window.setFrameAutosaveName('rspactor_main_window')    
  end
end
