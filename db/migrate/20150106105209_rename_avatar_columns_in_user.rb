class RenameAvatarColumnsInUser < ActiveRecord::Migration
  def up
    rename_column :users, :avatar_file_name,    :old_avatar_file_name
    rename_column :users, :avatar_content_type, :old_avatar_content_type
    rename_column :users, :avatar_file_size,    :old_avatar_file_size
    rename_column :users, :avatar_updated_at,   :old_avatar_updated_at

    rename_column :users, :c_image, :avatar
  end

  def down
    rename_column :users, :old_avatar_updated_at,   :avatar_updated_at
    rename_column :users, :old_avatar_file_size,    :avatar_file_size
    rename_column :users, :old_avatar_content_type, :avatar_content_type
    rename_column :users, :old_avatar_file_name,    :avatar_file_name

    rename_column :users, :avatar, :c_image
  end
end
