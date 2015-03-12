class CreateNewsletterRecipients < ActiveRecord::Migration
  def change
    create_table :newsletter_recipients do |t|
      t.references :user_profile, index: true
      t.references :newsletter, index: true
      t.boolean :opened, default: false

      t.timestamps
    end
  end
end
