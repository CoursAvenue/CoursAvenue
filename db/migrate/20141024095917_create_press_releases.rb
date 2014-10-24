class CreatePressReleases < ActiveRecord::Migration
  def change
    create_table :press_releases do |t|
      t.string   :title
      t.text     :description
      t.string   :slug
      t.text     :content
      t.boolean  :published
      t.datetime :published_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
