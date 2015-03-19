class AddPageDescriptionAndDescriptionToCategories < ActiveRecord::Migration
  def change
    add_column :blog_categories, :description, :text
    add_column :blog_categories, :page_description, :text
  end
end
