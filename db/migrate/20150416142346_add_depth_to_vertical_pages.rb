class AddDepthToVerticalPages < ActiveRecord::Migration
  def change
    add_column :vertical_pages, :depth, :integer
    VerticalPage.find_each do |vertical_page|
      if vertical_page.subject
        vertical_page.update_column :depth, vertical_page.subject.depth
      else
        vertical_page.update_column :depth, 0
      end
    end
  end
end
