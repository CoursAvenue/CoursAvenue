class AddPageTitleAndMetaDescriptionToVerticalPages < ActiveRecord::Migration
  def change
    add_column :vertical_pages, :page_title, :string
    add_column :vertical_pages, :page_description, :text
  end
end
