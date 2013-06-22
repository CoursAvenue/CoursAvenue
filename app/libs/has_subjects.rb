module HasSubjects

  def self.included(base)
    base.instance_eval do
      include ::HasSubjects::InstanceMethods
      after_save :update_subjects_string        # Save subjects as : "Subject name,subject-slug;Another subject name, another-subject-slug"
      after_save :update_parent_subjects_string # Save subjects as : "Subject name,subject-slug;Another subject name, another-subject-slug"
    end
  end

  module InstanceMethods
    def update_subjects_string
      subjects_array = []
      self.subjects.uniq.each do |subject|
        subjects_array << "#{subject.name},#{subject.slug}"
      end
      self.update_column :subjects_string, subjects_array.join(';')
    end

    def update_parent_subjects_string
      subjects_array = []
      self.subjects.uniq.collect{|subject| subject.parent || subject }.uniq.each do |subject|
        subjects_array << "#{subject.name},#{subject.slug}"
      end
      self.update_column :parent_subjects_string, subjects_array.join(';')
    end
  end
end
