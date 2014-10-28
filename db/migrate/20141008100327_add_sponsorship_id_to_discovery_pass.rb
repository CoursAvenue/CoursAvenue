class AddSponsorshipIdToDiscoveryPass < ActiveRecord::Migration
  def change
    add_column :discovery_passes, :sponsorship_id, :integer
  end
end
