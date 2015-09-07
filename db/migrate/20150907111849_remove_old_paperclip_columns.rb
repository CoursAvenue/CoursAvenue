class RemoveOldPaperclipColumns < ActiveRecord::Migration
  def change
    remove_column :press_articles, :old_logo_file_name
    remove_column :press_articles, :old_logo_content_type
    remove_column :press_articles, :old_logo_file_size
    remove_column :press_articles, :old_logo_updated_at

    remove_column :emailings, :old_header_image_file_name
    remove_column :emailings, :old_header_image_content_type
    remove_column :emailings, :old_header_image_file_size
    remove_column :emailings, :old_header_image_updated_at

    remove_column :teachers, :old_image_file_name
    remove_column :teachers, :old_image_content_type
    remove_column :teachers, :old_image_file_size
    remove_column :teachers, :old_image_updated_at
  end
end
