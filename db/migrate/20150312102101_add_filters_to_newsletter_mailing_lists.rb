class AddFiltersToNewsletterMailingLists < ActiveRecord::Migration
  def change
    add_column :newsletter_mailing_lists, :metadata, :hstore
  end
end
