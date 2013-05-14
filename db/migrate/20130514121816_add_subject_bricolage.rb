class AddSubjectBricolage < ActiveRecord::Migration
  def up
    subject_1        = Subject.where(name: 'Arts manuels').first
    bricolage        = Subject.create name: 'Bricolage'
    bricolage.parent = subject_1
    bricolage.save

    subject_2          = Subject.where(name: 'Ateliers enfants / duo parent-enfant').first
    bricolage_2        = Subject.create name: 'Bricolage'
    bricolage_2.parent = subject_2
    bricolage_2.save
  end

  def down
    Subject.where(name: 'Bricolage').delete_all
  end
end
