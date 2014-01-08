class AddEmailOptInNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_promo_opt_in,      :boolean, default: true
    add_column :users, :email_newsletter_opt_in, :boolean, default: true
    add_column :users, :email_passions_opt_in,   :boolean, default: true
    add_column :users, :sms_opt_in,              :boolean, default: true
  end
end
