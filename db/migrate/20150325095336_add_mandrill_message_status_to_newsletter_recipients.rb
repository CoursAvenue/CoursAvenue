class AddMandrillMessageStatusToNewsletterRecipients < ActiveRecord::Migration
  def change
    add_column :newsletter_recipients, :mandrill_message_status, :string
  end
end
