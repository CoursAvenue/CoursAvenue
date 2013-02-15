class CreatePlaceForStructuresWithoutAny < ActiveRecord::Migration
  def up
    Structure.all.each do |structure|
      place = Place.new({
        name:                 structure.name,
        street:               structure.street,
        zip_code:             structure.zip_code,
        nb_room:              structure.nb_room,
        has_handicap_access:  structure.has_handicap_access,
        info:                 structure.adress_info,
        contact_email:        structure.email_address,
        contact_phone:        structure.phone_number,
        contact_mobile_phone: structure.mobile_phone_number,
        latitude:             structure.latitude,
        longitude:            structure.longitude,
        gmaps:                structure.gmaps
      })
      place.city = structure.city
      place.save!
      structure.places << place
      structure.save!
    end
  end

  def down
    Place.delete_all
  end
end
