class AddNotificationsEmailOptInToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :newsletter_email_opt_in,     :boolean, default: true
    add_column :admins, :monday_email_opt_in,         :boolean, default: true
    add_column :admins, :thursday_email_opt_in,       :boolean, default: true
    add_column :admins, :student_action_email_opt_in, :boolean, default: true
  end
end
