class AddAltColumnToEmailing < ActiveRecord::Migration
  def change
    add_column :emailings, :alt, :string
  end
end
