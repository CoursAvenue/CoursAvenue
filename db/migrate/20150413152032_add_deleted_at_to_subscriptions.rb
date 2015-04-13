class AddDeletedAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :deleted_at, :timestamp
  end
end
