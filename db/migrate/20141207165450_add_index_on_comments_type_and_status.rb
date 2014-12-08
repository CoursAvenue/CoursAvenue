class AddIndexOnCommentsTypeAndStatus < ActiveRecord::Migration
  def change
    add_index :comments, [:type, :status]
  end
end
