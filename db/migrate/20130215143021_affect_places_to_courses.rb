class AffectPlacesToCourses < ActiveRecord::Migration
  def up
    Course.where{place_id == nil}.all.each do |course|
      course.update_attribute(:place_id, course.structure.places.first.id)
      course.save
    end
  end

  def down
  end
end
