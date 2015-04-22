class CreateStripeEvents < ActiveRecord::Migration
  def change
    create_table :stripe_events do |t|
      t.string :stripe_event_id

      t.timestamps
    end
    add_index :stripe_events, :stripe_event_id, unique: true
  end
end
