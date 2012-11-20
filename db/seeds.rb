# encoding: utf-8

## Discipline
Discipline.delete_all
Discipline.create(:name => "Party")
Discipline.create(:name => "Afro Tonic")
Discipline.create(:name => "Boxe Tonic")
Discipline.create(:name => "Housedance")
Discipline.create(:name => "Hip Hop")
Discipline.create(:name => "Dancehall")
Discipline.create(:name => "Jazz")
Discipline.create(:name => "Afro Tonic")
Discipline.create(:name => "Barre au sol contemporaine")
Discipline.create(:name => "Classique")
Discipline.create(:name => "Barre au sol")
Discipline.create(:name => "Méthode Feldenkrais")
Discipline.create(:name => "Contemporain")
Discipline.create(:name => "Cunningham")
Discipline.create(:name => "Pilates")
Discipline.create(:name => "Moderne")
Discipline.create(:name => "Modern' Jazz")
Discipline.create(:name => "Contemporain")
Discipline.create(:name => "Modern' Jazz")
Discipline.create(:name => "Break")
Discipline.create(:name => "Barre au sol Jazz")
Discipline.create(:name => "Contemporain")
Discipline.create(:name => "Hip Hop")
Discipline.create(:name => "Hip Hop New Style")
Discipline.create(:name => "Cabaret Talons")
Discipline.create(:name => "Lyrical Jazz")
Discipline.create(:name => "Yoga Vinyasa")
Discipline.create(:name => "Barre au sol classique")
zumba = Discipline.create(:name => "Zumba")

## Audiences
Audience.delete_all
Audience.create(:name => 'Adultes')
Audience.create(:name => 'Enfants')

## Levels
Level.delete_all
Level.create(:name => 'Débutant')
Level.create(:name => 'Moyen')
Level.create(:name => 'Avancé')

structure = Structure.create(:structure_type => 'Ecole privée',
                             :name           => 'Studio harmonic',
                             :street         => '5 passage des Taillandiers',
                             :zip_code       => '75011',
                             :website        => 'http://www.studioharmonic.fr/'
                             )

c = Course::Lesson.create(:lesson_info_1 => 'Lorem')
c.structure = structure
c.discipline = zumba
c.save
