class AddEmailOptInToStudents < ActiveRecord::Migration
  def change
    add_column :students, :email_opt_in, :boolean, default: true
  end
end
