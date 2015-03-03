class AddSmsOptInToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :sms_opt_in, :boolean, default: true
  end
end
