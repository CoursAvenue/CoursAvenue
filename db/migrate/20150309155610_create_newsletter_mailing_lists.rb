class CreateNewsletterMailingLists < ActiveRecord::Migration
  def change
    create_table :newsletter_mailing_lists do |t|
      t.references :newsletter

      t.timestamps
    end
  end
end
