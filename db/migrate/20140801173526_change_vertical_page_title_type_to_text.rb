class ChangeVerticalPageTitleTypeToText < ActiveRecord::Migration
  def change
    change_column :vertical_pages, :title, :text
  end
end
