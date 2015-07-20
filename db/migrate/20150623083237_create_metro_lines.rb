class CreateMetroLines < ActiveRecord::Migration
  def change
    create_table :metro_lines do |t|
      t.string :name
      t.string :slug
      t.integer :line_number

      t.timestamps
    end
  end
end
