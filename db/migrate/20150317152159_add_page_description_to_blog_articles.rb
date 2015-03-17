class AddPageDescriptionToBlogArticles < ActiveRecord::Migration
  def change
    add_column :blog_articles, :page_description, :text
  end
end
