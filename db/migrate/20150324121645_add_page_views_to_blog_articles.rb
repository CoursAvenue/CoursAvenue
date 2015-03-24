class AddPageViewsToBlogArticles < ActiveRecord::Migration
  def change
    add_column :blog_articles, :page_views, :integer, default: 0
  end
end
