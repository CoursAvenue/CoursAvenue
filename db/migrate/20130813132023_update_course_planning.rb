class UpdateCoursePlanning < ActiveRecord::Migration
  def up
    bar = ProgressBar.new( Course.count )
    Course.all.each do |course|
      bar.increment! 1
      course.plannings.each do |planning|
        planning.update_column :place_id, course.place_id unless course.place_id.nil?
      end
    end
  end

  def down
  end
end
