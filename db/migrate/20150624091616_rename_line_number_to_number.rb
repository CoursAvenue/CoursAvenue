class RenameLineNumberToNumber < ActiveRecord::Migration
  def change
    rename_column :metro_lines, :line_number, :number
  end
end
