class RemoveCropHeightForStructures < ActiveRecord::Migration
  def change
    remove_column :structures, :crop_height
    remove_column :structures, :cropping
  end
end
