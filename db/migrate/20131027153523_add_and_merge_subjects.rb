class AddAndMergeSubjects < ActiveRecord::Migration
  def change
    violon          = Subject.friendly.find 'violon'
    violon_and_alto = Subject.friendly.find 'violon-violoncelle-alto'
    (violon.structures + violon.courses).each do |obj|
      obj.subjects.delete(violon)
      obj.subjects << violon_and_alto
      obj.save
    end

    coaching_sportif         = Subject.friendly.find 'coaching-sportif'
    coaching_sportif_and_gym = Subject.friendly.find 'coaching-sportif-gym'
    (coaching_sportif.structures + coaching_sportif.courses).each do |obj|
      obj.subjects.delete(coaching_sportif)
      obj.subjects << coaching_sportif
      obj.save
    end

    sports = Subject.friendly.find 'sports-arts-martiaux'
    sports.children.create(name: 'Canne de combat')
  end
end
