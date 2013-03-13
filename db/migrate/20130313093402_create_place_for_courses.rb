class CreatePlaceForCourses < ActiveRecord::Migration
  def up
    Course.all.each do |course|
      if course.place.nil?
        course.update_column :place_id, course.structure.places.first.id
      end
    end
    Structure.all.each do |structure|
      place              = structure.places.first
      if place.nil?
        structure.zip_code = '75001'
        structure.city     = City.find('paris-01')
        structure.street   = 'Paris'
      else
        structure.zip_code = place.zip_code
        structure.city     = place.city
        structure.street  = place.street
      end
      structure.save
    end
  end

  def down
  end
end
