class RenameImageFromMedias < ActiveRecord::Migration
  def change
    rename_column :medias, :image_file_name, :old_image_file_name
    rename_column :medias, :image_file_size, :old_image_file_size
    rename_column :medias, :image_content_type, :old_image_content_type
    rename_column :medias, :image_updated_at, :old_image_updated_at

    rename_column :medias, :c_image, :image
  end
end
