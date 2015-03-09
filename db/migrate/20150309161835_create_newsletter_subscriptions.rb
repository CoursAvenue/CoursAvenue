class CreateNewsletterSubscriptions < ActiveRecord::Migration
  def change
    create_table :newsletter_subscriptions, :id => false do |t|
      t.references :newsletter_mailing_list, :user_profile

      t.timestamps
    end
    add_index :newsletter_subscriptions, [:newsletter_mailing_list_id, :user_profile_id], name: 'subscription_index'
  end
end
