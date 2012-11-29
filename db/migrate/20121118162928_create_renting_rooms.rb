class CreateRentingRooms < ActiveRecord::Migration
  def change
    create_table :renting_rooms do |t|
      t.string  :name
      t.integer :surface
      t.text    :info
      t.integer :regular_renting_price
      t.integer :minimum_price
      t.integer :maximum_price
      t.text    :price_info
      t.text    :contact_mail
      t.text    :contact_phone
      t.boolean :is_duty_free
      t.boolean :has_recording_studio
      t.boolean :has_cloakroom
      t.boolean :has_bars
      t.boolean :has_mirrors
      t.boolean :has_sound
      t.boolean :has_carpets
      t.boolean :has_parquet
      t.boolean :has_piano

      t.references :structure

      t.timestamps
    end
  end
end
