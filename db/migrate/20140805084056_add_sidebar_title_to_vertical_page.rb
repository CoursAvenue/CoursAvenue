class AddSidebarTitleToVerticalPage < ActiveRecord::Migration
  def change
    add_column :vertical_pages, :sidebar_title, :text
  end
end
