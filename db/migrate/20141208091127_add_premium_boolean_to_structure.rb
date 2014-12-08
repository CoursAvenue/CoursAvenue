class AddPremiumBooleanToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :premium, :boolean
    Structure.delay.update_premium_attribute
  end
end
