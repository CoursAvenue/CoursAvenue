class MigratePrivateCourses < ActiveRecord::Migration
  def change
    Course.where(is_individual: true).update_all type: 'Course::Private'
    Course.where(teaches_at_home: true).update_all type: 'Course::Private'
  end
end
