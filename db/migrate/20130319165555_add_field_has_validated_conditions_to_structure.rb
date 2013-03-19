class AddFieldHasValidatedConditionsToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :has_validated_conditions, :boolean, default: false
    add_column :structures, :validated_by, :integer
  end
end
