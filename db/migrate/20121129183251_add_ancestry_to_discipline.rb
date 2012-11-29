class AddAncestryToDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :ancestry, :string
  end

  def up
    add_index :disciplines, :ancestry
  end

  def down
    remove_index :disciplines, :ancestry
  end
end
