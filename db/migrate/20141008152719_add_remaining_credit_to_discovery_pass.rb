class AddRemainingCreditToDiscoveryPass < ActiveRecord::Migration
  def change
    add_column :discovery_passes, :remaining_credit, :integer
  end
end
