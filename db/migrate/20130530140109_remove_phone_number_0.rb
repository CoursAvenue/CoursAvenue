class RemovePhoneNumber0 < ActiveRecord::Migration
  def up
    Place.where{contact_phone == '0'}.all.each do |place|
      place.update_column(:contact_phone, nil)
    end

    Place.where{contact_mobile_phone == '0'}.all.each do |place|
      place.update_column(:contact_mobile_phone, nil)
    end

    Structure.where{phone_number == '0'}.all.each do |structure|
      structure.update_column(:phone_number, nil)
    end

    Structure.where{mobile_phone_number == '0'}.all.each do |structure|
      structure.update_column(:mobile_phone_number, nil)
    end
  end

  def down
  end
end
