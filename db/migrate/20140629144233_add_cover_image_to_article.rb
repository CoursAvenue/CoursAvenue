class AddCoverImageToArticle < ActiveRecord::Migration
  def change
    add_attachment :blog_articles, :cover_image
  end
end
