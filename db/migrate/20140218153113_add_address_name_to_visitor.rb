class AddAddressNameToVisitor < ActiveRecord::Migration
  def change
    add_column :visitors, :address_name, :hstore
  end
end
