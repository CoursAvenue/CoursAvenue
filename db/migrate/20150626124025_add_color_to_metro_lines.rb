class AddColorToMetroLines < ActiveRecord::Migration
  def change
    add_column :metro_lines, :color, :string
  end
end
