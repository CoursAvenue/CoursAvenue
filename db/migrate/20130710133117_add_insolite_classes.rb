# encoding: utf-8
class AddInsoliteClasses < ActiveRecord::Migration
  def up
    insolite_subject = Subject.where(name: 'Insolite').first
    child = insolite_subject.children.create name: 'In English please!'
    child.children.create name: 'Cours en anglais'

    child = insolite_subject.children.create name: 'Inclassables'
    child.children.create name: 'Inclassables'

    child = insolite_subject.children.create name: 'Monde'
    child.children.create name: "Découverte d'ailleurs"
  end

  def down
  end
end
