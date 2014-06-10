class CreatePhoneNumbers < ActiveRecord::Migration
  def up
    create_table :phone_numbers do |t|
      t.string  :number
      t.string  :phone_type
      t.integer :callable_id
      t.string  :callable_type

      t.timestamps
    end
    add_index :phone_numbers, :callable_type
    add_index :phone_numbers, :callable_id

    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      if structure.contact_phone.present?
        structure.phone_numbers.create(phone_type: 'phone_numbers.type.home', number: structure.contact_phone)
      end
      if structure.contact_mobile_phone.present?
        structure.phone_numbers.create(phone_type: 'phone_numbers.type.mobile', number: structure.contact_mobile_phone)
      end
      next if structure.main_contact.nil?
      if structure.main_contact.phone_number.present?
        structure.phone_numbers.create(phone_type: 'phone_numbers.type.home', number: structure.main_contact.phone_number)
      end
      if structure.main_contact.mobile_phone_number.present?
        structure.phone_numbers.create(phone_type: 'phone_numbers.type.mobile', number: structure.main_contact.mobile_phone_number)
      end
    end
  end

  def down
    drop_table :phone_numbers
  end
end
