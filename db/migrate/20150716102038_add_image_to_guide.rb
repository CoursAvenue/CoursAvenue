class AddImageToGuide < ActiveRecord::Migration
  def change
    add_column :guides, :image, :string
  end
end
