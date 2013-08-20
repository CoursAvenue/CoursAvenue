class AddDefaultValueToCropAttributes < ActiveRecord::Migration
  def change
    change_column :structures, :crop_x     , :integer, default: 0
    change_column :structures, :crop_y     , :integer, default: 0
    change_column :structures, :crop_width , :integer, default: 500
    change_column :structures, :crop_height, :integer, default: 500
    change_column :structures, :cropping   , :boolean, default: false
  end
end
