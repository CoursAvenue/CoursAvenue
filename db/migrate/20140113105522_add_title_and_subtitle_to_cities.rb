class AddTitleAndSubtitleToCities < ActiveRecord::Migration
  def change
    add_column :cities, :title, :text
    add_column :cities, :subtitle, :text
    add_column :cities, :description, :text
  end
end
