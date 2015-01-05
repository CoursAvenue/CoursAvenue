class AddPrincipalToPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :principal, :boolean, default: false
  end
end
