# encoding: utf-8
class AddVisualArtsSubjects < ActiveRecord::Migration
  def up
    s = Subject.find 'art-artisanat'
    s.children.create(name: 'Art visuel')
    s.children.create(name: 'Art numérique')
  end

  def down
  end
end
