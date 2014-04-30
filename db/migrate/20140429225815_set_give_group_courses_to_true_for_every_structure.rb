class SetGiveGroupCoursesToTrueForEveryStructure < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      structure.gives_non_professional_courses = true
      structure.save
    end
  end

  def down
  end
end
