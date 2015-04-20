class AddMetadataToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :metadata, :hstore
  end
end
