class AddDefaultToCommentsCount < ActiveRecord::Migration
  def change
    change_column :structures, :comments_count, :integer, default: 0
  end
end
