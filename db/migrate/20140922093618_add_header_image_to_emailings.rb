class AddHeaderImageToEmailings < ActiveRecord::Migration
  def up
    add_attachment :emailings, :header_image
  end

  def down
    remove_attachment :emailings, :header_image
  end
end
