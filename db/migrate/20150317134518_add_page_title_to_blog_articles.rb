class AddPageTitleToBlogArticles < ActiveRecord::Migration
  def change
    add_column :blog_articles, :page_title, :string
  end
end
