class AddParanoidToStructureCustomers < ActiveRecord::Migration
  def change
    add_column :structure_customers, :deleted_at, :datetime
  end
end
