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
        debugger
      else
        structure.zip_code = place.zip_code
        structure.city     = place.city
        structure.address  = place.street
      end
      structure.save
    end
  end

  def down
  end
end
