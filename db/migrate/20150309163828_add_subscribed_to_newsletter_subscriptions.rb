class AddSubscribedToNewsletterSubscriptions < ActiveRecord::Migration
  def change
    add_column :newsletter_subscriptions, :subscribed, :boolean, default: true
  end
end
