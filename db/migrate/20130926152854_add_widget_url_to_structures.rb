class AddWidgetUrlToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :widget_url, :text
  end
end
