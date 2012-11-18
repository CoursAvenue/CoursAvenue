class AddAncestryToDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :ancestry, :string
    add_index :disciplines, :ancestry
  end
end
