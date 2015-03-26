class AddMandrillMessageIdToNewsletterRecipients < ActiveRecord::Migration
  def change
    add_column :newsletter_recipients, :mandrill_message_id, :integer
  end
end
