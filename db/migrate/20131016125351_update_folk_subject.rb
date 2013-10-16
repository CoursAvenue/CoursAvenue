class UpdateFolkSubject < ActiveRecord::Migration
  def change
    to_remove      = Subject.find('danses-folkloriques-traditionnelles')
    to_change_with = Subject.find('danses-folks-de-caractere-traditionnelles')
    to_remove.courses.each do |course|
      course.subjects.delete(to_remove)
      course.subjects << to_change_with
      course.save
      course.index
    end
    to_remove.structures.each do |structure|
      structure.subjects.delete(to_remove)
      structure.subjects << to_change_with
      structure.save
      structure.index
    end
    to_remove.destroy
  end
end
