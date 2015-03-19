class AddImageToBlogArticles < ActiveRecord::Migration
  def change
    add_column :blog_articles, :image, :string
  end
end
