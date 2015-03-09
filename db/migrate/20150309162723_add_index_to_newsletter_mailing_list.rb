class AddIndexToNewsletterMailingList < ActiveRecord::Migration
  def change
    add_index :newsletter_mailing_lists, :newsletter_id
    add_index :newsletter_blocs, :newsletter_id
  end
end
