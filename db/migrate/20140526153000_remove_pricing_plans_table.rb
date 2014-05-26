class RemovePricingPlansTable < ActiveRecord::Migration
  def up
    drop_table :pricing_plans
    remove_column :structures, :pricing_plan_id
    add_column    :structures, :pricing_plan, :string
    Structure.update_all pricing_plan: 'free'
  end

  def down
    add_column    :structures, :pricing_plan_id, :integer
    remove_column :structures, :pricing_plan
    create_table :pricing_plans do |t|
      t.string  :name
      t.decimal :price
      t.timestamps
    end
  end
end
