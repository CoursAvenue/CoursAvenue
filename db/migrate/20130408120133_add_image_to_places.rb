class AddImageToPlaces < ActiveRecord::Migration
  def change
    add_attachment :places, :image
  end
end
