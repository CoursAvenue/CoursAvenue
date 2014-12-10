class AddIndexOnSubscriptionPlansStrutcureId < ActiveRecord::Migration
  def change
    add_index :subscription_plans, :structure_id
  end
end
