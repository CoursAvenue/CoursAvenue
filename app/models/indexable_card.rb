class IndexableCard < ActiveRecord::Base
  belongs_to :structure
  belongs_to :place
  belongs_to :planning
  belongs_to :course

  attr_accessible :structure, :subject, :place, :planning, :course

  delegate :name, to: :course, prefix: true

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    add_attribute :name do
      self.course_name || self.subject_name
    end
  end
  # :nocov:

  def self.create_from_planning(planning)
    create(planning:  planning,
           structure: planning.structure,
           place:     planning.place,
           course:    planning.course)
  end

  def self.create_from_subject_and_place(subject, place)
    create(subject:   subject,
           place:     place,
           structure: place.structure)
  end
end
