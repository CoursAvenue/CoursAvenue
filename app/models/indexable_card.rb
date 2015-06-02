class IndexableCard < ActiveRecord::Base
  belongs_to :structure
  belongs_to :subject
  belongs_to :place
  belongs_to :planning
  belongs_to :course

  attr_accessible :structure, :subject, :place, :planning, :course

  def self.create_from_planning(planning)
    create(planning:  planning,
           structure: planning.structure,
           place:     planning.place,
           # subject:   planning.subject,
           course:    planning.course)
  end

  def self.create_from_subject_and_place(subject, place)
    create(subject:   subject,
           place:     place,
           structure: place.structure)
  end
end
