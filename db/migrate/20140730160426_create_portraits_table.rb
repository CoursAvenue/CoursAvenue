class CreatePortraitsTable < ActiveRecord::Migration
  def change
    create_table :portraits do |t|
      t.string :thumb_title
      t.string :thumb_subtitle
      t.text :title
      t.text :quote_name
      t.text :quote
      t.text :top_line
      t.text :content
      t.text :bottom_line

      t.string :slug

      t.boolean :visible

      t.timestamps
    end
  end
end
