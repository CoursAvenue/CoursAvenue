# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

## Audiences
Audience.delete_all
Audience.create(:name => 'Adultes')
Audience.create(:name => 'Enfants')

## Levels
Level.delete_all
Level.create(:name => 'Débutant')
Level.create(:name => 'Moyen')
Level.create(:name => 'Avancé')

