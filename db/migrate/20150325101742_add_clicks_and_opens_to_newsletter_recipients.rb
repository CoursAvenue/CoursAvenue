class AddClicksAndOpensToNewsletterRecipients < ActiveRecord::Migration
  def change
    add_column :newsletter_recipients, :clicks, :integer
    add_column :newsletter_recipients, :opens, :integer
  end
end
