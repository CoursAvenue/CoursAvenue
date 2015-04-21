class RemoveUnusedColumnsFromStructures < ActiveRecord::Migration
  def change
    remove_column :structures, :registration_info
    remove_column :structures, :info
    remove_column :structures, :has_validated_conditions
    remove_column :structures, :validated_by
    remove_column :structures, :rating
    remove_column :structures, :sticker_status
  end
end
