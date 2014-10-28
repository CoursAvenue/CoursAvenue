class AddMetaDataToDiscoveryPass < ActiveRecord::Migration
  def change
    add_column :discovery_passes, :meta_data, :hstore
  end
end
