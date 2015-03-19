class AddAncestryToBlogCategories < ActiveRecord::Migration
  def change
    add_column :blog_categories, :ancestry, :string
    add_index  :blog_categories, :ancestry

    add_column :blog_categories, :ancestry_depth, :integer, :default => 0
    add_index  :blog_categories, :ancestry_depth
  end
end
