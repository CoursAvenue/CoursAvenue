class AddDeletedAtColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :time
  end
end
