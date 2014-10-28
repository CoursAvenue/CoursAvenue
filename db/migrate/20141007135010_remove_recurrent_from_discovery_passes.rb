class RemoveRecurrentFromDiscoveryPasses < ActiveRecord::Migration
  def change
    remove_column :discovery_passes, :promotion_code_id
    remove_column :discovery_passes, :recurrent
  end
end
