class AddInfoToRegistrationFeeAndRemmoveForKid < ActiveRecord::Migration
  def up
    remove_column :registration_fees, :for_kid
    add_column :registration_fees, :info, :string
  end

  def down
    add_column :registration_fees, :for_kid, :boolean
    remove_column :registration_fees, :info
  end
end
