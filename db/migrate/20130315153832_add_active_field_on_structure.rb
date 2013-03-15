class AddActiveFieldOnStructure < ActiveRecord::Migration
  def change
    add_column :structures, :active, :boolean, default: false
    Structure.all.each do |structure|
      structure.active = true
      structure.save
    end
  end
end
