class RenameImageFromMedias < ActiveRecord::Migration
  def change
    rename_column :medias, :image_file_name, :image
  end
end
