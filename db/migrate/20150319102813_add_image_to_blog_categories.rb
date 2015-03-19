class AddImageToBlogCategories < ActiveRecord::Migration
  def change
    add_column :blog_categories, :image, :string
  end
end
