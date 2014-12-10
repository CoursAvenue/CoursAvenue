class AddImageToFlyers < ActiveRecord::Migration
  def change
    add_column :flyers, :image, :string
  end
end
