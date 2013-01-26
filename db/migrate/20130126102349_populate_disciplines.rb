# encoding: utf-8
class PopulateDisciplines < ActiveRecord::Migration
  def up
    #--------------------------------------------------------------- Dance
    dance        = Discipline.create name: 'Danse'
    dance_childs = ['Barre au sol', 'Cabaret / Pole Dance', 'Claquettes', 'Classique', 'Comédie musicale', 'Contemporaine / Moderne', 'Danse du monde', 'Hip Hop / Dancehall', "Jazz / Modern' Jazz", 'Relaxation', 'Street / Break', 'Tonic', 'Zumba']
    dance_childs.each do |dance_child_name|
      dance_child        = Discipline.create name: dance_child_name
      dance_child.parent = dance
      dance_child.save
    end

    #--------------------------------------------------------------- Sport
    sport        = Discipline.create name: 'Sport'
    sport_childs = ['Sport', 'Combat / Art martial', 'Escrime', 'Gym', 'Natation', 'Tennis de table', 'Art martial', 'Éveil', 'Stretching / Etirements', 'Renforcement musculaire', 'Plongée']
    sport_childs.each do |sport_child_name|
      sport_child        = Discipline.create name: sport_child_name
      sport_child.parent = sport
      sport_child.save
    end

    #--------------------------------------------------------------- Arts et Sciences
    arts_and_science        = Discipline.create name: 'Arts et Sciences'
    arts_and_science_childs = ['Culture artistique', 'Observations / Découvertes', 'Écologie', 'Robotique', 'Archéologie']
    arts_and_science_childs.each do |arts_and_science_child_name|
      arts_and_science_child        = Discipline.create name: arts_and_science_child_name
      arts_and_science_child.parent = arts_and_science
      arts_and_science_child.save
    end

    #--------------------------------------------------------------- Enseignement
    learning        = Discipline.create name: 'Enseignement'
    learning_childs = ['Langues', 'Histoire', 'Ecriture']
    learning_childs.each do |learning_child_name|
      learning_child        = Discipline.create name: learning_child_name
      learning_child.parent = learning
      learning_child.save
    end

    #--------------------------------------------------------------- Arts graphiques et plastiques
    arts_and_graphics        = Discipline.create name: 'Arts graphiques et plastiques'
    arts_and_graphics_childs = ['Dessin', 'Arts plastiques', 'Peinture', 'Calligraphie', 'Magie', 'Photo', 'Cinéma / Animation', 'Vidéo', 'Peinture', 'Ecriture']
    arts_and_graphics_childs.each do |arts_and_graphics_child_name|
      arts_and_graphics_child        = Discipline.create name: arts_and_graphics_child_name
      arts_and_graphics_child.parent = arts_and_graphics
      arts_and_graphics_child.save
    end

    #--------------------------------------------------------------- Chant
    sing        = Discipline.create name: 'Chant'
    sing_childs = ['Chant', 'Chant & instrument', 'Chorale', 'Culture artistique', 'Ecriture', 'Entraînement vocal', 'Technique vocale / musicale', 'Voix & scène']
    sing_childs.each do |sing_child_name|
      sing_child        = Discipline.create name: sing_child_name
      sing_child.parent = sing
      sing_child.save
    end

    #--------------------------------------------------------------- Arts du spectacle
    spectacle        = Discipline.create name: 'Arts du spectacle'
    spectacle_childs = ['Comédie / Humour', 'Comédie musicale', 'Éveil', 'Impro', 'Texte / Interprétation', 'Cirque', 'Théâtre', 'Magie', 'Lecture / Contes', 'Création (composition, écriture)']
    spectacle_childs.each do |spectacle_child_name|
      spectacle_child        = Discipline.create name: spectacle_child_name
      spectacle_child.parent = spectacle
      spectacle_child.save
    end

    #--------------------------------------------------------------- Insolite
    insolite        = Discipline.create name: 'Insolite'
    insolite_childs = ['Instrument & langue', 'Recyclage', 'DJ / Mix', 'Gemmologie', 'Nature', 'Robotique', 'Monde']
    insolite_childs.each do |insolite_child_name|
      insolite_child        = Discipline.create name: insolite_child_name
      insolite_child.parent = insolite
      insolite_child.save
    end

    #--------------------------------------------------------------- Music
    music        = Discipline.create name: 'Musique / Instruments'
    music_childs = ['Chant & instrument', 'Culture artistique', 'Éveil', 'Instrument', 'Solfège', 'Technique musicale / instrumentale', 'Ensembles instrumentaux', 'Instrument du monde']
    music_childs.each do |music_child_name|
      music_child        = Discipline.create name: music_child_name
      music_child.parent = music
      music_child.save
    end

    #--------------------------------------------------------------- Relaxation
    relaxation        = Discipline.create name: 'Relaxation / Fitness'
    relaxation_childs = ['Danse Fitness', 'Danse relaxation', 'Fitness', 'Relaxation / Gym douce', 'Yoga', 'Stretching / Etirements']
    relaxation_childs.each do |relaxation_child_name|
      relaxation_child        = Discipline.create name: relaxation_child_name
      relaxation_child.parent = relaxation
      relaxation_child.save
    end

    #--------------------------------------------------------------- Arts manuels
    manual_art        = Discipline.create name: 'Arts manuels'
    manual_art_childs = ['Encadrement', 'Poterie / Modelage', 'Couture', 'Divers', 'Scrapbooking', 'Sculpture', 'Art floral', 'Mode / Maquillage']
    manual_art_childs.each do |manual_art_child_name|
      manual_art_child        = Discipline.create name: manual_art_child_name
      manual_art_child.parent = manual_art
      manual_art_child.save
    end

    #--------------------------------------------------------------- Cuisine / Œnologie
    cooking        = Discipline.create name: 'Cuisine / Œnologie'
    cooking_childs = ['Cuisine', 'Pâtisserie', 'Cuisine du monde', 'Chocolats', 'Vins & Chocolats', 'Bières', 'Champagne', 'Insolite', 'Mets & Vins', 'Fromages', 'Apéro', 'Cocktails', 'Bio']
    cooking_childs.each do |cooking_child_name|
      cooking_child        = Discipline.create name: cooking_child_name
      cooking_child.parent = cooking
      cooking_child.save
    end

    #--------------------------------------------------------------- Atelier petite enfance / parents-nourrisson
    parent_kids        = Discipline.create name: 'Atelier petite enfance / parents-nourrisson'
    parent_kids_childs = ['Musique', 'Natation', 'Théâtre', 'Danse', 'Gym', 'Expression artistique', 'Cuisine / Pâtisserie']
    parent_kids_childs.each do |parent_kids_child_name|
      parent_kids_child        = Discipline.create name: parent_kids_child_name
      parent_kids_child.parent = parent_kids
      parent_kids_child.save
    end
  end

  def down
    Discipline.delete_all
  end
end


