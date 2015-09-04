class CreateStructureCustomers < ActiveRecord::Migration
  def change
    create_table :structure_customers do |t|
      t.references :structure, index: true
      t.string :stripe_customer_id

      t.timestamps
    end
  end
end
