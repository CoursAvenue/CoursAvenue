class ChangeRemainingCreditTypeFromIntegerToFloatInDiscoveryPass < ActiveRecord::Migration
  def change
    change_column :discovery_passes, :remaining_credit, :float
  end
end
