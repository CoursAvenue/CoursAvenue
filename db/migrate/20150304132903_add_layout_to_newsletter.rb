class AddLayoutToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :layout_id, :integer, index: true
  end
end
