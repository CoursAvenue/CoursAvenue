class AddPositionToBlogCategories < ActiveRecord::Migration
  def change
    add_column :blog_categories, :position, :integer
  end
end
