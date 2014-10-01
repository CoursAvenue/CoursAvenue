class AddCImageToMedias < ActiveRecord::Migration
  def change
    add_column :medias, :c_image, :string
  end
end
