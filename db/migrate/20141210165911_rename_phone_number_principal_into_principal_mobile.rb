class RenamePhoneNumberPrincipalIntoPrincipalMobile < ActiveRecord::Migration
  def change
    rename_column :phone_numbers, :principal, :principal_mobile
  end
end
