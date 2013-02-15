class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string  :name
      t.string  :street
      t.text    :info
      t.string  :zip_code
      t.boolean :has_handicap_access
      t.integer :nb_room
      t.string  :contact_name
      t.string  :contact_phone
      t.string  :contact_mobile_phone
      t.string  :contact_email

      t.references :structure
      t.references :city
      t.timestamps
    end
  end
end
