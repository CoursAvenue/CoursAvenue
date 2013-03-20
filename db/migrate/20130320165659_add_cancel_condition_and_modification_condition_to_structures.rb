class AddCancelConditionAndModificationConditionToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :cancel_condition, :string
    add_column :structures, :modification_condition, :string
  end
end
