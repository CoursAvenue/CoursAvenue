# encoding: utf-8
class PopulateDisciplines < ActiveRecord::Migration
  def up
    #--------------------------------------------------------------- Dance
    dance        = Discipline.create name: 'Danse'
    dance_childs = ['Barre au sol', 'Cabaret / Pole Dance', 'Claquettes', 'Classique', 'Comédie musicale / Chorégraphie', 'Contemporaine / Moderne', 'Danse Fitness / Step', 'Danse petite enfance', 'Danses de couple', 'Danses du monde', 'Hip Hop / Dancehall', "Jazz / Modern' Jazz", 'Rock', 'Street / Break', 'Zumba', 'Développement personnel-']
    dance_childs.each do |dance_child_name|
      dance_child        = Discipline.create name: dance_child_name
      dance_child.parent = dance
      dance_child.save
    end

    #--------------------------------------------------------------- Sport
    sport        = Discipline.create name: 'Sport'
    sport_childs = ['Art martial', 'Autres sports', 'Combat / Art martiaux', 'Escrime', 'Etirements', 'Gym', 'Natation', 'Plongée', 'Renforcement musculaire', 'Tennis de table', "Tir à l'arc"]
    sport_childs.each do |sport_child_name|
      sport_child        = Discipline.create name: sport_child_name
      sport_child.parent = sport
      sport_child.save
    end

    #--------------------------------------------------------------- Arts et Sciences
    arts_and_science        = Discipline.create name: 'Arts et Sciences'
    arts_and_science_childs = ['Archéologie' ,'Culture artistique' ,'Écologie' ,'Observations / Découvertes' ,'Robotique' ,'Santé']
    arts_and_science_childs.each do |arts_and_science_child_name|
      arts_and_science_child        = Discipline.create name: arts_and_science_child_name
      arts_and_science_child.parent = arts_and_science
      arts_and_science_child.save
    end

    #--------------------------------------------------------------- Enseignement
    learning        = Discipline.create name: 'Enseignement'
    learning_childs = ['Ecriture', 'Histoire', 'Informatique', 'Langues étrangère', 'Soutien scolaire', 'Insolite-']
    learning_childs.each do |learning_child_name|
      learning_child        = Discipline.create name: learning_child_name
      learning_child.parent = learning
      learning_child.save
    end

    #--------------------------------------------------------------- Arts graphiques et plastiques
    arts_and_graphics        = Discipline.create name: 'Arts visuels et plastiques'
    arts_and_graphics_childs = ['Arts plastiques', 'Calligraphie', 'Cinéma / Animation', 'Dessin', "L'art d'écrire", 'Peinture', 'Photo', 'Vidéo', 'Arts manuels-']
    arts_and_graphics_childs.each do |arts_and_graphics_child_name|
      arts_and_graphics_child        = Discipline.create name: arts_and_graphics_child_name
      arts_and_graphics_child.parent = arts_and_graphics
      arts_and_graphics_child.save
    end

    #--------------------------------------------------------------- Chant
    sing        = Discipline.create name: 'Chant'
    sing_childs = ['Chant-', 'Chant & instrument', 'Chorale', 'Entraînement vocal', 'Technique vocale / musicale', 'Textes & écriture', 'Voix & scène']
    sing_childs.each do |sing_child_name|
      sing_child        = Discipline.create name: sing_child_name
      sing_child.parent = sing
      sing_child.save
    end

    #--------------------------------------------------------------- Arts du spectacle
    spectacle        = Discipline.create name: 'Arts du spectacle'
    spectacle_childs = ['Cirque' ,'Comédie / Humour' ,'Création (composition, écriture)' ,'Expression scénique' ,'Impro' ,'Lecture / Contes' ,'Magie' ,'Spectacle petite enfance' ,'Texte / Interprétation' ,'Théâtre']
    spectacle_childs.each do |spectacle_child_name|
      spectacle_child        = Discipline.create name: spectacle_child_name
      spectacle_child.parent = spectacle
      spectacle_child.save
    end

    #--------------------------------------------------------------- Insolite
    insolite        = Discipline.create name: 'Insolite'
    insolite_childs = ['2 cours en 1', 'DJ / Mix', 'Femmes enceintes', 'Gemmologie', 'In English please!', 'Inclassables', 'Monde', 'Nature', 'Recyclage', 'Sciences', 'Musique / Instruments-']
    insolite_childs.each do |insolite_child_name|
      insolite_child        = Discipline.create name: insolite_child_name
      insolite_child.parent = insolite
      insolite_child.save
    end

    #--------------------------------------------------------------- Music
    music        = Discipline.create name: 'Musique / Instruments'
    music_childs = ['Chant & instruments', 'Culture musicale', 'Ensembles instrumentaux', 'Instruments', 'Instruments du monde', 'Musique petite enfance', 'Solfège', 'Technique musicale / instrumentale', 'Relaxation / Fitness-']
    music_childs.each do |music_child_name|
      music_child        = Discipline.create name: music_child_name
      music_child.parent = music
      music_child.save
    end

    #--------------------------------------------------------------- Relaxation
    relaxation        = Discipline.create name: 'Relaxation / Fitness'
    relaxation_childs = ['Danse Fitness / Fitness', 'Danse relaxation', 'Pilates', 'Relaxation / Gym douce', 'Stretching / Etirements', 'Yoga', 'Sport-']
    relaxation_childs.each do |relaxation_child_name|
      relaxation_child        = Discipline.create name: relaxation_child_name
      relaxation_child.parent = relaxation
      relaxation_child.save
    end

    #--------------------------------------------------------------- Arts manuels
    manual_art        = Discipline.create name: 'Arts manuels'
    manual_art_childs = ['Art floral', 'Couture', 'Divers', 'Encadrement', 'Mode / Maquillage', 'Poterie / Modelage', 'Scrapbooking', 'Sculpture', 'Atelier petite enfance / duo parent-enfant-']
    manual_art_childs.each do |manual_art_child_name|
      manual_art_child        = Discipline.create name: manual_art_child_name
      manual_art_child.parent = manual_art
      manual_art_child.save
    end

    #--------------------------------------------------------------- Cuisine / Œnologie
    cooking        = Discipline.create name: 'Cuisine / Œnologie'
    cooking_childs = ['Cuisine / Œnologie', 'Bières', 'Bio', 'Champagne', 'Chocolats', 'Cocktails / Apéro', 'Cuisine', 'Cuisines du monde', 'Fromages', 'Insolite', 'Mets & Vins', 'Pâtisserie / Boulangerie', 'Vins & Chocolats', 'Whisky']
    cooking_childs.each do |cooking_child_name|
      cooking_child        = Discipline.create name: cooking_child_name
      cooking_child.parent = cooking
      cooking_child.save
    end

    #--------------------------------------------------------------- Atelier petite enfance / parents-nourrisson
    parent_kids        = Discipline.create name: 'Atelier petite enfance / duo parent-enfant'
    parent_kids_childs = ['Atelier couleur', 'Atelier découverte', 'Atelier expression', 'Atelier gourmand', 'Danse éveil', 'Expression artistique', 'Musique éveil', 'Sport éveil', 'Théâtre éveil', 'Chant-']
    parent_kids_childs.each do |parent_kids_child_name|
      parent_kids_child        = Discipline.create name: parent_kids_child_name
      parent_kids_child.parent = parent_kids
      parent_kids_child.save
    end

    personal_development        = Discipline.create name: 'Développement personnel'
    personal_development_childs = ['Cours de rire', 'Expression / Prise de parole en public', 'Enseignement']
    personal_development_childs.each do |personal_development_child_name|
      personal_development_child        = Discipline.create name: personal_development_child_name
      personal_development_child.parent = personal_development
      personal_development_child.save
    end
  end

  def down
    Discipline.delete_all
  end
end
