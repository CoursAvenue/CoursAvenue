class UpdateCourseTypeOfPriceGroups < ActiveRecord::Migration
  def change
    PriceGroup.where(course_type: 'Course::Lesson').update_all course_type: 'regular'
    PriceGroup.where(course_type: 'Course::Private').update_all course_type: 'regular'
    PriceGroup.where(course_type: 'Course::Training').update_all course_type: 'training'
  end
end
