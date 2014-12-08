class AddIndexOnCommentsStatus < ActiveRecord::Migration
  def change
    add_index :comments, :status
  end
end
