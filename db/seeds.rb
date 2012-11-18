# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

## Discipline
Discipline.delete_all
dance = Discipline.create(:name => 'Danse')
zumba = Discipline.create(:name => 'Zumba')
zumba.parent = dance
zumba.save!

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
