class AddParentSubjectIfHasNot < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Structure.count
    Structure.all.each do |structure|
      bar.increment!
      structure.subjects.each do |subject|
        if subject.ancestry_depth == 1
          structure.subjects << subject.parent
          structure.subjects.delete(subject)
        elsif subject.ancestry_depth == 2
          structure.subjects << subject.parent.parent
        end
        structure.save
      end
    end
  end

  def down
  end
end
