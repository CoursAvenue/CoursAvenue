class AddUndercoresToFirstAndLastName < ActiveRecord::Migration
  def change
    rename_column :admins, :firstname, :first_name
    rename_column :admins, :lastname, :last_name
  end
end
