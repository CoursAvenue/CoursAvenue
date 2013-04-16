class MergeFirstAndLastNameForReservation < ActiveRecord::Migration
  def up
    rename_column :reservations, :first_name, :name
    remove_column :reservations, :last_name
  end

  def down
    rename_column :reservations, :name, :first_name
    add_column    :reservations, :last_name, :string
  end
end
