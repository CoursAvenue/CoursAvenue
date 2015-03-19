class AddSubtitleToBlogCategories < ActiveRecord::Migration
  def change
    add_column :blog_categories, :subtitle, :string
  end
end
