class AffectPlaceToCourses < ActiveRecord::Migration
  def up
    Course.all.each do |course|
      if course.place.nil?
        course.update_attribute :place_id, course.structure.places.first.id
      end
    end
  end

  def down
  end
end
