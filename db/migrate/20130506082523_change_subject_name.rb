class ChangeSubjectName < ActiveRecord::Migration
  def up
    subject = Subject.where(name: 'Natation').first
    subject.name = 'Natation / Aquagym'
    subject.save
  end

  def down
    subject = Subject.where(name: 'Natation / Aquagym').first
    subject.name = 'Natation'
    subject.save
  end
end
