class AddClImageToVerticalPages < ActiveRecord::Migration
  def change
    add_column :vertical_pages, :cl_image, :string
  end
end
