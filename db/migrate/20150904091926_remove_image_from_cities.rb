class RemoveImageFromCities < ActiveRecord::Migration
  def change
    remove_column :cities, :image_file_name
    remove_column :cities, :image_content_type
    remove_column :cities, :image_file_size
    remove_column :cities, :image_updated_at
  end
end
