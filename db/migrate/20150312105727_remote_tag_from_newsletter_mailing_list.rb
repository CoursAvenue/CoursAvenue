class RemoteTagFromNewsletterMailingList < ActiveRecord::Migration
  def change
    remove_column :newsletter_mailing_lists, :tag
  end
end
