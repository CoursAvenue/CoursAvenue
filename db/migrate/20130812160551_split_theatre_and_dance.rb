# encoding: utf-8
class SplitTheatreAndDance < ActiveRecord::Migration
  def up

    theatre = Subject.find 'theatre-danse'
    theatre.name = 'Théâtre'
    theatre.save

    dance          = Subject.create name: 'Danse', position: 1
    children_dance = ['salsa', 'jazz-modern-jazz', 'rock-danses-de-salon', 'comedie-musicale-choregraphies', 'tango', 'pole-dance', 'fusion', 'danse-classique', 'danse-contemporaine', 'barre-au-sol-assouplissements', 'corps-mouvement', 'dance-floor', 'danse-orientale', 'danse-africaine', 'ecoles-de-danses', 'danses-folkloriques-traditionnelles', 'danse-fitness', 'flamenco', 'danses-urbaines', 'danses-du-monde']
    children_dance.each do |children_subject|
      child = Subject.find children_subject
      child.parent = dance
      child.save
    end

    children_theatre = ['pantins-marionnettes', 'pratiques-theatrales-mixtes', 'theatre-de-rue', 'theatre-no-kabuki', 'conteurs-conteuses', 'costumes-decors', 'decouverte-du-theatre', 'ecriture-theatrale--3', 'formation-d-acteurs', 'improvisation-theatrale', 'comedie-humour', 'mise-en-scene-expression-scenique']
    children_theatre.each do |child_name|
      child = Subject.find child_name
      child.parent = theatre
      child.save
      child.children.create name: child.name
    end
    Subject.find('theatre').delete
    theatre.update_column :slug, 'theatre'

    Place.where{parent_subjects_string =~ '%theatre-danse%'}.each do |place|
      place.delay.touch
    end
    Structure.where{parent_subjects_string =~ '%theatre-danse%'}.each do |structure|
      structure.delay.touch
    end
  end

  def down
  end
end
