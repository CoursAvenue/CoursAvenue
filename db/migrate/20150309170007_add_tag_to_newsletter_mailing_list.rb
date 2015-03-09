class AddTagToNewsletterMailingList < ActiveRecord::Migration
  def change
    add_column :newsletter_mailing_lists, :tag, :string
    add_column :newsletter_mailing_lists, :name, :string
  end
end
