class RemovePrincipalMobileAndAddPrincipalMobileIdToStructure < ActiveRecord::Migration
  def change
    remove_column :phone_numbers, :principal_mobile
    add_column :structures, :principal_mobile_id, :integer
    add_index :structures, :principal_mobile_id
  end
end
