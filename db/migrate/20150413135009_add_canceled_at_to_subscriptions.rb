class AddCanceledAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :canceled_at, :datetime
  end
end
