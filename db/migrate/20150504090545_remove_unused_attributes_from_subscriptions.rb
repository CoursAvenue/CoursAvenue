class RemoveUnusedAttributesFromSubscriptions < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :name
    remove_column :subscriptions, :price
    remove_column :subscriptions, :interval
  end

  def down
    add_column :subscriptions, :name, :string
    add_column :subscriptions, :price, :integer
    add_column :subscriptions, :interval, :string
  end
end
