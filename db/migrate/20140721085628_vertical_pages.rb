class VerticalPages < ActiveRecord::Migration
  def change
    create_table :vertical_pages do |t|
      t.string     :name
      t.text       :caption
      t.string     :title
      t.text       :content
      t.text       :keywords
      t.string     :slug

      t.references :subject

      t.timestamps
    end
  end
end
