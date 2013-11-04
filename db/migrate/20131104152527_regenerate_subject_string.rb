class RegenerateSubjectString < ActiveRecord::Migration
  def change
    Structure.all.map(&:update_subjects_string)
    Course.all.map(&:update_subjects_string)
  end
end
