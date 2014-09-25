module HasSubjects

  def self.included(base)
    base.instance_eval do
      include ::HasSubjects::InstanceMethods
      after_touch :update_subjects_string        # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
      after_touch :update_parent_subjects_string # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
      after_save  :update_subjects_string        # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
      after_save  :update_parent_subjects_string # Save subjects as : "Subject name:subject-slug;Anothersubject name: another-subject-slug"
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

    def parent_subjects_array
      self.parent_subjects_string.split(';').collect do |subject_string|
        subject_name, subject_slug = subject_string.split(':')
        {name: subject_name, slug: subject_slug}
      end
    end

    # Returns all the subjects objects
    def subjects_array
      self.subjects_string.split(';').collect do |subject_string|
        subject_name, subject_slug = subject_string.split(':')
        {name: subject_name, slug: subject_slug}
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

    def update_parent_subjects_string
      subjects_array = []
      self.subjects.at_depth(0).each do |subject|
        subjects_array << "#{subject.name}:#{subject.slug}"
      end
      self.update_column :parent_subjects_string, subjects_array.join(';')
      self.update_column :updated_at, Time.now
    end
  end
end
