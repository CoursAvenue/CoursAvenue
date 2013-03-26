class AddCityToPlacesWithout < ActiveRecord::Migration
  def change
    Course.all.each do |course|
      if course.place.nil?
        course.room = course.structure.rooms.first
        course.save
      end
    end
  end
end
