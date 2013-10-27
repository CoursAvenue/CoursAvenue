class UpdateUsersExtraInfo < ActiveRecord::Migration
  def up
    rename_column :users, :birthday, :birthdate
    remove_column :users, :age
  end

  def down
    rename_column :users, :birthdate, :birthday
    add_column :users, :age, :integer
  end
end
