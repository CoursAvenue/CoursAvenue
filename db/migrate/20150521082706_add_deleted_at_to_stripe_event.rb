class AddDeletedAtToStripeEvent < ActiveRecord::Migration
  def change
    add_column :stripe_events, :deleted_at, :datetime
  end
end
