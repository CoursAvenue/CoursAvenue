class AddDeliveryEmailStatusToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :delivery_email_status, :string
  end
end
