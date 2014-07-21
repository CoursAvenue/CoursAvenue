class AddCheckedAndCommentsToVerticalPages < ActiveRecord::Migration
  def change
    add_column :vertical_pages, :checked, :boolean, default: false
    add_column :vertical_pages, :comments, :text
  end
end
