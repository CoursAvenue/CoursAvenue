class ChangeRemainingCreditTypeFromFloatToDecimalInDiscoveryPass < ActiveRecord::Migration
  def change
    change_column :discovery_passes, :remaining_credit, :decimal
  end
end
