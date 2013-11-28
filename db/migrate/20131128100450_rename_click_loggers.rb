class RenameClickLoggers < ActiveRecord::Migration
  def up
    rename_table :click_loggers, :click_logs
    add_column :click_logs, :structure_id, :integer
    add_column :click_logs, :info, :text

    add_index :click_logs, :structure_id

    ClickLog.delete_all
  end

  def down
    rename_table :click_logs, :click_loggers
    remove_column :click_loggers, :structure_id
  end

end
