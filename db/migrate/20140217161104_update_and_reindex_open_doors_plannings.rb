class UpdateAndReindexOpenDoorsPlannings < ActiveRecord::Migration
  def change
    Course::Open.all.map(&:plannings).flatten.map(&:index)
    Course::Open.all.map(&:structure).map{ |course| course.send(:update_meta_datas) }
  end
end
