class RenameAltToHeaderImageAltForEmailings < ActiveRecord::Migration
  def change
    rename_column :emailings, :alt, :header_image_alt
  end
end
