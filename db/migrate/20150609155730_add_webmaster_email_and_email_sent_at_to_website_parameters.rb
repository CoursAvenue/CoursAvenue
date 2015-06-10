class AddWebmasterEmailAndEmailSentAtToWebsiteParameters < ActiveRecord::Migration
  def change
    add_column :website_parameters, :webmaster_email, :string
    add_column :website_parameters, :webmaster_email_sent_at, :datetime
  end
end
