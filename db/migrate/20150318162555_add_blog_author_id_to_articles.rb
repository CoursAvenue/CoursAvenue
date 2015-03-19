class AddBlogAuthorIdToArticles < ActiveRecord::Migration
  def change
    add_column :blog_articles, :author_id, :integer
  end
end
