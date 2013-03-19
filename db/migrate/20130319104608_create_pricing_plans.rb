class CreatePricingPlans < ActiveRecord::Migration
  def change
    create_table :pricing_plans do |t|
      t.string  :name
      t.decimal :price
      t.timestamps
    end
    PricingPlan.create(name: 'free', price: 0)
    add_column :structures, :pricing_plan_id, :integer
  end
end
