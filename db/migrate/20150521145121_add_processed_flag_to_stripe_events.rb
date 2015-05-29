class AddProcessedFlagToStripeEvents < ActiveRecord::Migration
  def change
    add_column :stripe_events, :processed, :boolean, default: false
  end
end
