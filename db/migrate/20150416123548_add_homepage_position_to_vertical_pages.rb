class AddHomepagePositionToVerticalPages < ActiveRecord::Migration
  def change
    add_column :vertical_pages, :homepage_position, :integer
  end
end
