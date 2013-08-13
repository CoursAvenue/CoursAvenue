class RemoveImageFromPlace < ActiveRecord::Migration
  def change
    remove_attachment :places, :image
    remove_attachment :places, :thumb_image
  end
end
