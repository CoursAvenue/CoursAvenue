# encoding: utf-8
class AddNumeriqueArts < ActiveRecord::Migration
  def up
    s = Subject.find 'cinema-video'
    s.children.create name: 'Arts numériques'
  end

  def down
  end
end
