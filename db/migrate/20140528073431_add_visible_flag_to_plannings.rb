class AddVisibleFlagToPlannings < ActiveRecord::Migration
  def change
    add_column :plannings, :visible, :boolean, default: true
    Planning.update_all visible: true
  end
end
