class UpdateMusicSubjects < ActiveRecord::Migration
  def up
    # delete_subject 'ecoles-centres-academies-de-musique'
    delete_subject 'conservatoires-de-musique'
    instrument_de_musique = rename_subject 'lutherie', 'Instrument de musique'
    update_parent 'mixage-dj', 'musiques-actuelles'
    musique_par_style     = rename_subject 'musique-classique', 'Musique par style'
    update_parent 'jazz', musique_par_style
    jazz_rock = Subject.friendly.find 'musique-jazz-rock'
    jazz_rock.children.each do |child|
      child.parent = musique_par_style
      child.save
    end
    jazz_rock.destroy

    culture_musicale = rename_subject 'culture-musicale', 'Culture musicale'
    culture_musicale.parent = instrument_de_musique
    culture_musicale.save
    delete_subject 'musique-instruments--2'

    musique_par_instrument = Subject.friendly.find('musique-par-instrument')
    musique_par_instrument.children.each do |child|
      child.parent = instrument_de_musique
      child.save
    end
    rename_subject 'toutes-percussions', 'Percussions'
    rename_subject 'fanfare', 'Fanfare & batucada'
    delete_subject 'percussions-orientales'
    delete_subject 'percussions-insolites'
    delete_subject 'rap'
    musique_par_instrument.destroy

    update_parent 'son-lumiere', 'theatre'
    update_parent 'preparation-a-la-scene-aux-concerts', 'son-lumiere'
    delete_subject 'scene-voix'
    update_parent 'rythme-musical', 'decouverte-de-la-musique'
    delete_subject 'travail-rythmique'
    delete_subject 'ecoles-de-musique'
  end

  def down
  end

  def rename_subject slug, new_name
    subject      = Subject.friendly.find slug
    subject.name = new_name
    subject.save
    return subject
  end

  def delete_subject slug
    subject      = Subject.friendly.find slug
    subject.destroy
  end

  def delete_subjects slugs
    slugs.each do |slug|
      delete_subject(slug)
    end
  end

  def update_parent slug, parent_slug
    child  = Subject.friendly.find(slug)
    parent = Subject.friendly.find(parent_slug)
    child.parent = parent
    child.save
  end
end
