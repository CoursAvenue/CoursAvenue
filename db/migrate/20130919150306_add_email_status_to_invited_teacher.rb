class AddEmailStatusToInvitedTeacher < ActiveRecord::Migration
  def change
    add_column :invited_teachers, :email_status, :string
    add_column :invited_teachers, :registered, :boolean, default: false
    InvitedTeacher.all.each do |invited_teacher|
      if Admin.where(email: invited_teacher.email).count > 0
        invited_teacher.update_column :registered, true
      end
    end

  end
end
