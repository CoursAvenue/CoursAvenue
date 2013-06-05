class AddStructureIdToUsers < ActiveRecord::Migration
  def change
    rename_table :newsletter_users, :students
  end
end
