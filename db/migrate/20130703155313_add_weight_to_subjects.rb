# encoding: utf-8
class AddWeightToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :position, :integer

    subjects = ["Théâtre & Danse" ,"Musique & Chant" ,"Cuisine & Vins" ,"Enfants & Ados" ,"Loisirs créatifs" ,"Art & Artisanat" ,"Bien-être & Santé" ,"Photo & Vidéo" ,"Sports"]
    subjects.each_with_index do |subject_name, index|
      s = Subject.where{(name == subject_name) & (ancestry == nil)}.first
      s.update_column :position, (index + 1)
    end
  end
end
