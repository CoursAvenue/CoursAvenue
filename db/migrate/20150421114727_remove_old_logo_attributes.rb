class RemoveOldLogoAttributes < ActiveRecord::Migration
  def change
    remove_column :structures, :old_logo_file_name
    remove_column :structures, :old_logo_content_type
    remove_column :structures, :old_logo_file_size
    remove_column :structures, :old_logo_updated_at
    remove_column :structures, :old_sleeping_logo_file_name
    remove_column :structures, :old_sleeping_logo_content_type
    remove_column :structures, :old_sleeping_logo_file_size
    remove_column :structures, :old_sleeping_logo_updated_at

    remove_column :users, :old_avatar_file_name
    remove_column :users, :old_avatar_content_type
    remove_column :users, :old_avatar_file_size
    remove_column :users, :old_avatar_updated_at

    remove_column :medias, :old_image_file_name
    remove_column :medias, :old_image_content_type
    remove_column :medias, :old_image_file_size
    remove_column :medias, :old_image_updated_at
  end
end
