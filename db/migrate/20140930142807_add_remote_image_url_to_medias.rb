class AddRemoteImageUrlToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :remote_image_url, :string
  end
end
