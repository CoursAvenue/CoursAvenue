class AddInfoToPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :info, :string
  end
end
