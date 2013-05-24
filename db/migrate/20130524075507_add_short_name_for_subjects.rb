# encoding: utf-8
class AddShortNameForSubjects < ActiveRecord::Migration
  def up
    add_column :subjects, :short_name, :string

    dance                = Subject.where(name: 'Danse').first
    dance.update_column :short_name, 'Danse'

    sport                = Subject.where(name: 'Sport').first
    sport.update_column :short_name, 'Sport'

    arts_and_science     = Subject.where(name: 'Arts et Sciences').first
    arts_and_science.update_column :short_name, 'Sciences'

    learning             = Subject.where(name: 'Enseignement').first
    learning.update_column :short_name, 'Enseignement'

    arts_and_graphics    = Subject.where(name: 'Arts visuels et plastiques').first
    arts_and_graphics.update_column :short_name, 'Arts'

    sing                 = Subject.where(name: 'Chant / Voix').first
    sing.update_column :short_name, 'Chant'

    spectacle            = Subject.where(name: 'Arts du spectacle').first
    spectacle.update_column :short_name, 'Spectacle'

    insolite             = Subject.where(name: 'Insolite').first
    insolite.update_column :short_name, 'Insolite'

    music                = Subject.where(name: 'Musique / Instruments').first
    music.update_column :short_name, 'Musique'

    relaxation           = Subject.where(name: 'Relaxation / Fitness').first
    relaxation.update_column :short_name, 'Fitness'

    manual_art           = Subject.where(name: 'Arts manuels').first
    manual_art.update_column :short_name, 'Manuels'

    cooking              = Subject.where(name: 'Cuisine / Œnologie').first
    cooking.update_column :short_name, 'Cuisine'

    parent_kids          = Subject.where(name: 'Ateliers enfants / duo parent-enfant').first
    parent_kids.update_column :short_name, 'Enfants'

    personal_development = Subject.where(name: 'Développement personnel').first
    personal_development.update_column :short_name, 'Dév. personnel'
  end

  def down
    remove_column :subjects, :short_name
  end
end
