class AddDefaultToRemainingCreditColumnInDiscoveryPass < ActiveRecord::Migration
  def change
    change_column :discovery_passes, :remaining_credit, :integer, default: 38
  end
end
