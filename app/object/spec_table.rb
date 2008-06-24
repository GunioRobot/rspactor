require 'osx/cocoa'

class SpecTable < OSX::NSObject
  include OSX
  
  ib_outlet :specsTable
  
  def awakeFromNib
    receive :NSTableViewSelectionDidChangeNotification, :disableTableRowMarking
    receive :spec_run_example_passed,                   :specRunFinishedSingleSpec
    receive :spec_run_example_pending,                  :specRunFinishedSingleSpec
    receive :spec_run_example_failed,                   :specRunFinishedSingleSpec
    receive :first_failed_spec,                         :markFileContainingFirstFailedSpec
    receive :file_table_reload_required,                :reload_required
  end
  
  def specRunFinishedSingleSpec(notification)
    reload!
  end
  
  def markFileContainingFirstFailedSpec(notification)
    @byFirstFailingSpecSelectedRowIndex = $spec_list.index_by_spec(notification.userInfo.first)
  end
  
  def reload_required(notification)
    reload!
  end
  
  def reload!
    @specsTable.reloadData
    if @byFirstFailingSpecSelectedRowIndex
      $app.post_notification :retain_focus_on_drawer
      @specsTable.selectRowIndexes_byExtendingSelection(NSIndexSet.new.initWithIndex(@byFirstFailingSpecSelectedRowIndex), false)
    end
  end
  
  def disableTableRowMarking(notification)
    @byFirstFailingSpecSelectedRowIndex = nil
  end
  
  # def clearSelection
  #   $allSpecsTableView.deselectAll(self)
  # end
  
  def numberOfRowsInTableView(specTable)
    $spec_list.files.size
  end

  def tableView_objectValueForTableColumn_row(specTable, specTableColumn, rowIndex)
    return unless $spec_list && file = $spec_list.file_by_index(rowIndex)
    file.name
  end

end
