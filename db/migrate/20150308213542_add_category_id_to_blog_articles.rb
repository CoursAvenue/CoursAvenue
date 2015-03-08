class AddCategoryIdToBlogArticles < ActiveRecord::Migration
  def change
    add_column :blog_articles, :category_id, :integer
  end
end
