class AddAncestryToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :ancestry, :string
  end

  def up
    add_index :subjects, :ancestry
  end

  def down
    remove_index :subjects, :ancestry
  end
end
