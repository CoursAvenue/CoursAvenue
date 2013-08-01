class RenameContactPhoneOnStructure < ActiveRecord::Migration
  def change
    rename_column :structures, :phone_number       , :contact_phone
    rename_column :structures, :mobile_phone_number, :contact_mobile_phone
  end
end
