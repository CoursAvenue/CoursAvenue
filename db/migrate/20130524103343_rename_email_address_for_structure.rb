class RenameEmailAddressForStructure < ActiveRecord::Migration
  def change
    rename_column :structures, :email_address, :contact_email
  end
end
