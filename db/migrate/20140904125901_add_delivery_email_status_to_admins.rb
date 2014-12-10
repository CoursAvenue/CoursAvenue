class AddDeliveryEmailStatusToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :delivery_email_status, :string
  end
end
