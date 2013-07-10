# encoding: utf-8
class RemoveOldSubjects < ActiveRecord::Migration
  def up
    parent_subject = Subject.where(name: 'Arts manuels').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy

    parent_subject = Subject.where(name: 'Arts visuels et plastiques').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy

    parent_subject = Subject.where(name: 'Ateliers enfants / duo parent-enfant').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy

    parent_subject = Subject.where(name: 'Chant / Voix').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy

    parent_subject = Subject.where(name: 'Cuisine / Œnologie').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy

    parent_subject = Subject.where(name: 'Développement personnel').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy

    parent_subject = Subject.where(name: 'Enseignement').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy

    parent_subject = Subject.where(name: 'Musique / Instruments').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy

    parent_subject = Subject.where(name: 'Spectacle / Théâtre').first
    puts "Removing #{parent_subject.name} with #{parent_subject.children.length} children"
    parent_subject.children.each do |children|
      children.destroy
    end
    parent_subject.destroy


  end

  def down
  end
end
