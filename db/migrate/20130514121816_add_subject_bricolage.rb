class AddSubjectBricolage < ActiveRecord::Migration
  def up
    subject_1 = Subject.where(name: 'Arts manuels').first
    bricolage        = Subject.create name: 'Bricolage'
    bricolage.parent = subject_1

    subject_2 = Subject.where(name: 'Ateliers enfants / duo parent-enfant').first
    bricolage        = Subject.create name: 'Bricolage'
    bricolage.parent = subject_2
  end

  def down
  end
end
