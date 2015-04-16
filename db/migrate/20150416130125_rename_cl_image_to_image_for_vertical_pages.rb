class RenameClImageToImageForVerticalPages < ActiveRecord::Migration
  def change
    remove_column :vertical_pages, :image_file_name
    remove_column :vertical_pages, :image_content_type
    remove_column :vertical_pages, :image_file_size
    remove_column :vertical_pages, :image_updated_at
    rename_column :vertical_pages, :cl_image, :image
  end
end
