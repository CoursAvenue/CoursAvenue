class CreatePressArticles < ActiveRecord::Migration
  def change
    create_table :press_articles do |t|
      t.string     :title
      t.text       :url
      t.text       :description
      t.date       :published_at
      t.attachment :logo

      t.timestamps
    end
  end
end
