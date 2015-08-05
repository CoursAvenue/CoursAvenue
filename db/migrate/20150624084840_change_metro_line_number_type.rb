class ChangeMetroLineNumberType < ActiveRecord::Migration
  def up
    change_column :metro_lines, :line_number, :string
  end

  def down
    change_column :metro_lines, :line_number, :integer
  end
end
