class AddColorToBlogCategories < ActiveRecord::Migration
  def change
    add_column :blog_categories, :color, :string
  end
end
