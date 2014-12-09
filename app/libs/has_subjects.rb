module HasSubjects

  def self.included(base)
    base.instance_eval do
      include ::HasSubjects::InstanceMethods
      after_touch :update_subjects_string        # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
      after_touch :update_parent_subjects_string # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
      after_touch :update_course_subjects_string # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
      after_save  :update_subjects_string        # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
      after_save  :update_parent_subjects_string # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
      after_save  :update_course_subjects_string # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
    end
  end

  module InstanceMethods
    # Returns all the parent subjects objects
    def parent_subjects
      self.parent_subjects_string.split(';').collect do |subject_string|
        subject_name, subject_slug = subject_string.split(':')
        Subject.friendly.find(subject_slug)
      end
    end

    def update_subjects_string
      subjects_array = []
      self.subjects.at_depth(2).uniq.each do |subject|
        subjects_array << "#{subject.name}:#{subject.slug}"
      end
      self.update_column :subjects_string, subjects_array.join(';')
      self.update_column :updated_at, Time.now
    end

    def update_course_subjects_string
      return unless self.respond_to?(:courses)
      subjects_array = []
      self.courses.flat_map(&:subjects).uniq.each do |subject|
        subjects_array << "#{subject.name}:#{subject.slug}"
      end
      self.update_column :course_subjects_string, subjects_array.join(';')
      self.update_column :updated_at, Time.now
    end

    def update_parent_subjects_string
      subjects_array = []
      self.subjects.at_depth(0).uniq.each do |root_subject|
        # subjects_array << "#{subject.name}:#{subject.slug}"
        # Get child subjects to order root subjects regarding the number of child it has
        child_subjects = self.subjects.at_depth(2).uniq.order('name ASC').select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
        subjects_array << {
          string: "#{root_subject.name}:#{root_subject.slug}",
          child_length: child_subjects.length
        }
      end
      subjects_array = subjects_array.sort{ |subj| subj[:child_length] }.reverse.map{ |subj| subj[:string] }
      self.update_column :parent_subjects_string, subjects_array.join(';')
      self.update_column :updated_at, Time.now
    end
  end

  # Return an array of subject's name regarding the key passed.
  # By default return parents subjects
  #
  # @return Array of String
  def subjects_name_as_string(key=:parent_subjects_string)
    self.send(key).split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      subject_name
    end
  end
end

