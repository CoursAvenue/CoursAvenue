class AddEventTypeToStripeEvents < ActiveRecord::Migration
  def change
    add_column :stripe_events, :event_type, :string
  end
end
