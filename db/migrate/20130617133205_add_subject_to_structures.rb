class AddSubjectToStructures < ActiveRecord::Migration
  def change
    Structure.all.each do |structure|
      structure.subjects << structure.courses.map{ |c| c.subjects }.flatten.uniq
      structure.save
    end
  end
end
