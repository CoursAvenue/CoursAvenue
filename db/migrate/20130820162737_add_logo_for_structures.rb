class AddLogoForStructures < ActiveRecord::Migration
  def change
    add_attachment :structures, :logo

    add_column :structures, :crop_x     , :integer
    add_column :structures, :crop_y     , :integer
    add_column :structures, :crop_width , :integer
    add_column :structures, :crop_height, :integer
    add_column :structures, :cropping   , :boolean
  end
end
