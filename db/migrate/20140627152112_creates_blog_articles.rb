class CreatesBlogArticles < ActiveRecord::Migration
  def change
    create_table :blog_articles do |t|
      t.string  :title
      t.string  :slug
      t.text    :description
      t.text    :content
      t.boolean :published

      t.timestamps
    end
  end
end
