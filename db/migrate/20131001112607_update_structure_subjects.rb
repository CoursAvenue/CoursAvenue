class UpdateStructureSubjects < ActiveRecord::Migration
  def up
    bar = ProgressBar.new(Structure.count + Course.count)
    Structure.all.each do |structure|
      bar.increment!
      structure.subjects_string.split(';').each do |subject_string|
        if Subject.where{slug == subject_string.split(',')[1]}.any?
          structure.subjects << Subject.where{slug == subject_string.split(',')[1]}.first
          structure.save
        end
      end
      structure.parent_subjects_string.split(';').each do |subject_string|
        if Subject.where{slug == subject_string.split(',')[1]}.any?
          structure.subjects << Subject.where{slug == subject_string.split(',')[1]}.first
          structure.save
        end
      end
    end

    Course.all.each do |course|
      bar.increment!
      course.subjects_string.split(';').each do |subject_string|
        if Subject.where{slug == subject_string.split(',')[1]}.any?
          course.subjects << Subject.where{slug == subject_string.split(',')[1]}.first
          course.save
        end
        if course.subjects.empty? and course.structure.subjects.at_depth(0).present?
          course.subjects << course.structure.subjects.at_depth(0)
          course.save
        end
      end
      course.parent_subjects_string.split(';').each do |subject_string|
        if Subject.where{slug == subject_string.split(',')[1]}.any?
          course.subjects << Subject.where{slug == subject_string.split(',')[1]}.first
          course.save
        end
        if course.subjects.empty? and course.structure.subjects.at_depth(0).present?
          course.subjects << course.structure.subjects.at_depth(0)
          course.save
        end
      end
    end
  end

  def down
  end
end
