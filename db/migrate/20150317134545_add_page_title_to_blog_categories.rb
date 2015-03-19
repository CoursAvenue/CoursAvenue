class AddPageTitleToBlogCategories < ActiveRecord::Migration
  def change
    add_column :blog_categories, :page_title, :string
  end
end
