class RemoveGymndouce < ActiveRecord::Migration
  def change
    gymnastique_douce                       = Subject.find 'gymnastique-douce'
    gymnastique_douce_stretching_etirements = Subject.find 'gymnastique-douce-stretching-etirements'
    (gymnastique_douce.structures + gymnastique_douce.courses).each do |instance|
      instance.subjects.delete(gymnastique_douce)
      instance.subjects << gymnastique_douce_stretching_etirements
      instance.save
    end
    gymnastique_douce.destroy
  end
end
