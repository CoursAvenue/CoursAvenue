class UpdateAndReindexOpenDoorsPlannings < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Course::Open.count
    Course::Open.find_each do |course|
      bar.increment!
      course.plannings.map(&:index)
      course.structure.send(:update_meta_datas)
    end
  end

  def down
  end
end
