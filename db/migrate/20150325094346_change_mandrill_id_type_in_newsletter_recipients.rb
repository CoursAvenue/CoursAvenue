class ChangeMandrillIdTypeInNewsletterRecipients < ActiveRecord::Migration
  def change
    change_column :newsletter_recipients, :mandrill_message_id, :string
  end
end
