class UpdateSubjectPosition < ActiveRecord::Migration
  def up
    add_index :subjects, :position
    s = Subject.find 'danse'
    s.update_column :position, 1
    s = Subject.find 'theatre-scene'
    s.update_column :position, 2
    s = Subject.find 'yoga-bien-etre-sante'
    s.update_column :position, 3
    s = Subject.find 'musique-chant'
    s.update_column :position, 4
    s = Subject.find 'dessin-peinture-arts-plastiques'
    s.update_column :position, 5
    s = Subject.find 'sports-arts-martiaux'
    s.update_column :position, 6
    s = Subject.find 'cuisine-vins'
    s.update_column :position, 7
    s = Subject.find 'photo-video'
    s.update_column :position, 8
    s = Subject.find 'deco-mode-bricolage'
    s.update_column :position, 9
    s = Subject.find 'culture-sciences-nature'
    s.update_column :position, 10
    s = Subject.find 'business-informatique'
    s.update_column :position, 11
    s = Subject.find 'langues-soutien-scolaire'
    s.update_column :position, 12

    s = Subject.find 'theatre'
    s.update_column :position, nil
  end

  def down
    remove_index :subjects, :position
  end
end
