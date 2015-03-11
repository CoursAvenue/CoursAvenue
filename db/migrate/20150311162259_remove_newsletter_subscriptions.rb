class RemoveNewsletterSubscriptions < ActiveRecord::Migration
  def change
    drop_table :newsletter_subscriptions
  end
end
