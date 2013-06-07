class AddEmailStatusToStudents < ActiveRecord::Migration
  def change
    add_column :students, :email_status, :string
  end
end
