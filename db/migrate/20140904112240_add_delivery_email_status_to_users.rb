class AddDeliveryEmailStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :delivery_email_status, :string
  end
end
