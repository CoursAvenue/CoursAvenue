class RemoveNewsletterFromNewsletterMailingLists < ActiveRecord::Migration
  def change
    remove_column :newsletter_mailing_lists, :newsletter_id, :integer
  end
end
