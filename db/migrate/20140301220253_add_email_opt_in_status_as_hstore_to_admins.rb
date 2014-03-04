class AddEmailOptInStatusAsHstoreToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :email_opt_in_status, :hstore
    bar = ProgressBar.new Admin.count
    Admin.find_each do |admin|
      bar.increment!
      admin.student_action_email_opt_in = admin.read_attribute(:student_action_email_opt_in)
      admin.newsletter_email_opt_in     = admin.read_attribute(:newsletter_email_opt_in)
      admin.monday_email_opt_in         = admin.read_attribute(:monday_email_opt_in)
      admin.thursday_email_opt_in       = admin.read_attribute(:thursday_email_opt_in)
      admin.jpo_email_opt_in            = true
      admin.save
    end
    remove_column :admins, :student_action_email_opt_in
    remove_column :admins, :newsletter_email_opt_in
    remove_column :admins, :monday_email_opt_in
    remove_column :admins, :thursday_email_opt_in
  end
end
