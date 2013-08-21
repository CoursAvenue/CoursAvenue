class RemoveDuplicateSubjects < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Subject.children.count
    Subject.children.each do |subject|
      subject_name = subject.name
      if (subjects = Subject.where{name == subject_name}).count == 2
        duplicate_subject = subjects.last

        if duplicate_subject.courses.count > 0
          duplicate_subject.courses.each do |course|
            course.subjects.delete duplicate_subject
            course.subjects << subject
            course.save
          end
        end
        duplicate_subject.destroy
      end
      bar.increment!
    end
  end

  def down
  end
end
