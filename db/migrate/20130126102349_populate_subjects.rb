# encoding: utf-8
class PopulateSubjects < ActiveRecord::Migration
  def up
    #--------------------------------------------------------------- Dance
    dance        = Subject.create name: 'Danse'
    dance_childs = ['Barre au sol', 'Cabaret / Pole Dance', 'Claquettes', 'Classique', 'Comédie musicale / Chorégraphie', 'Contemporaine / Moderne', 'Danse Fitness / Step', 'Danse petite enfance', 'Danses de couple', 'Danses du monde', 'Hip Hop / Dancehall', "Jazz / Modern' Jazz", 'Rock', 'Street / Break', 'Zumba']
    dance_childs.each do |dance_child_name|
      dance_child        = Subject.create name: dance_child_name
      dance_child.parent = dance
      dance_child.save
    end

    #--------------------------------------------------------------- Sport
    sport        = Subject.create name: 'Sport'
    sport_childs = ['Autres sports', 'Combat / Arts martiaux', 'Escrime', 'Etirements', 'Gym', 'Natation', 'Renforcement musculaire', 'Tennis de table', "Tir à l'arc"]
    sport_childs.each do |sport_child_name|
      sport_child        = Subject.create name: sport_child_name
      sport_child.parent = sport
      sport_child.save
    end

    #--------------------------------------------------------------- Arts et Sciences
    arts_and_science        = Subject.create name: 'Arts et Sciences'
    arts_and_science_childs = ['Archéologie', 'Culture artistique', 'Écologie', 'Observations / Nature', 'Robotique', 'Santé']
    arts_and_science_childs.each do |arts_and_science_child_name|
      arts_and_science_child        = Subject.create name: arts_and_science_child_name
      arts_and_science_child.parent = arts_and_science
      arts_and_science_child.save
    end

    #--------------------------------------------------------------- Enseignement
    learning        = Subject.create name: 'Enseignement'
    learning_childs = ['Ecriture', 'Histoire', 'Informatique', 'Langues étrangère', 'Soutien scolaire']
    learning_childs.each do |learning_child_name|
      learning_child        = Subject.create name: learning_child_name
      learning_child.parent = learning
      learning_child.save
    end

    #--------------------------------------------------------------- Arts graphiques et plastiques
    arts_and_graphics        = Subject.create name: 'Arts visuels et plastiques'
    arts_and_graphics_childs = ['Arts plastiques', 'Calligraphie', 'Cinéma / Animation', 'Dessin', "L'art d'écrire", 'Peinture', 'Photo', 'Vidéo']
    arts_and_graphics_childs.each do |arts_and_graphics_child_name|
      arts_and_graphics_child        = Subject.create name: arts_and_graphics_child_name
      arts_and_graphics_child.parent = arts_and_graphics
      arts_and_graphics_child.save
    end

    #--------------------------------------------------------------- Chant
    sing        = Subject.create name: 'Chant / Voix'
    sing_childs = ['Chant', 'Chant & instrument', 'Chorale', 'Entraînement vocal', 'Technique vocale / musicale', 'Textes & écriture', 'Voix & scène']
    sing_childs.each do |sing_child_name|
      sing_child        = Subject.create name: sing_child_name
      sing_child.parent = sing
      sing_child.save
    end

    #--------------------------------------------------------------- Arts du spectacle
    spectacle        = Subject.create name: 'Arts du spectacle'
    spectacle_childs = ['Cirque', 'Comédie / Humour', 'Création (composition, écriture)', 'Expression scénique', 'Impro', 'Lecture / Contes', 'Magie', 'Spectacle petite enfance', 'Théâtre', 'Mime']
    spectacle_childs.each do |spectacle_child_name|
      spectacle_child        = Subject.create name: spectacle_child_name
      spectacle_child.parent = spectacle
      spectacle_child.save
    end

    #--------------------------------------------------------------- Insolite
    insolite        = Subject.create name: 'Insolite'
    insolite_childs = ['2 cours en 1', 'DJ / Mix', 'Femmes enceintes', 'Gemmologie', 'In English please!', 'Inclassables', 'Monde', 'Nature', 'Recyclage', 'Sciences']
    insolite_childs.each do |insolite_child_name|
      insolite_child        = Subject.create name: insolite_child_name
      insolite_child.parent = insolite
      insolite_child.save
    end

    #--------------------------------------------------------------- Music
    music        = Subject.create name: 'Musique / Instruments'
    music_childs = ['Culture musicale', 'Ensembles instrumentaux', 'Instruments', 'Instruments du monde', 'Musique petite enfance', 'Solfège', 'Technique musicale / instrumentale']
    music_childs.each do |music_child_name|
      music_child        = Subject.create name: music_child_name
      music_child.parent = music
      music_child.save
    end

    #--------------------------------------------------------------- Relaxation
    relaxation        = Subject.create name: 'Relaxation / Fitness'
    relaxation_childs = ['Danse Fitness / Fitness', 'Danse relaxation', 'Pilates', 'Relaxation / Gym douce', 'Stretching / Etirements', 'Yoga']
    relaxation_childs.each do |relaxation_child_name|
      relaxation_child        = Subject.create name: relaxation_child_name
      relaxation_child.parent = relaxation
      relaxation_child.save
    end

    #--------------------------------------------------------------- Arts manuels
    manual_art        = Subject.create name: 'Arts manuels'
    manual_art_childs = ['Art floral', 'Couture', 'Divers', 'Encadrement', 'Mode / Maquillage', 'Poterie / Modelage', 'Scrapbooking', 'Sculpture']
    manual_art_childs.each do |manual_art_child_name|
      manual_art_child        = Subject.create name: manual_art_child_name
      manual_art_child.parent = manual_art
      manual_art_child.save
    end

    #--------------------------------------------------------------- Cuisine / Œnologie
    cooking        = Subject.create name: 'Cuisine / Œnologie'
    cooking_childs = ['Bières', 'Bio', 'Champagne', 'Chocolats', 'Cocktails / Apéro', 'Cuisine', 'Cuisines du monde', 'Fromages', 'Hors du commun', 'Pâtisserie / Boulangerie', 'Vins', 'Vins & mets / chocolats', 'Whisky']
    cooking_childs.each do |cooking_child_name|
      cooking_child        = Subject.create name: cooking_child_name
      cooking_child.parent = cooking
      cooking_child.save
    end

    #--------------------------------------------------------------- Atelier petite enfance / parents-nourrisson
    parent_kids        = Subject.create name: 'Ateliers enfants / duo parent-enfant'
    parent_kids_childs = ['Atelier couleur', 'Atelier création / Découverte', 'Atelier expression', 'Atelier gourmand', 'Danse éveil', 'Musique éveil', 'Sport éveil', 'Théâtre éveil']
    parent_kids_childs.each do |parent_kids_child_name|
      parent_kids_child        = Subject.create name: parent_kids_child_name
      parent_kids_child.parent = parent_kids
      parent_kids_child.save
    end

    personal_development        = Subject.create name: 'Développement personnel'
    personal_development_childs = ['Cours de rire', 'Expression / Prise de parole en public', 'Enseignement']
    personal_development_childs.each do |personal_development_child_name|
      personal_development_child        = Subject.create name: personal_development_child_name
      personal_development_child.parent = personal_development
      personal_development_child.save
    end
  end

  def down
    Subject.delete_all
  end
end
