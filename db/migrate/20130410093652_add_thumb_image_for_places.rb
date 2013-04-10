class AddThumbImageForPlaces < ActiveRecord::Migration
  def change
    add_attachment :places, :thumb_image
  end
end
