class AddImageToMedias < ActiveRecord::Migration
  def change
    add_attachment :medias, :image
    add_column :medias, :image_processing, :boolean
  end
end
