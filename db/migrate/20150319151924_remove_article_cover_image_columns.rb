class RemoveArticleCoverImageColumns < ActiveRecord::Migration
  def change
    remove_column :blog_articles, :cover_image_file_name
    remove_column :blog_articles, :cover_image_content_type
    remove_column :blog_articles, :cover_image_file_size
    remove_column :blog_articles, :cover_image_updated_at
  end
end
