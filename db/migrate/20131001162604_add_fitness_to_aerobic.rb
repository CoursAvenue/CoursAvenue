# encoding: utf-8
class AddFitnessToAerobic < ActiveRecord::Migration
  def change
    s = Subject.friendly.find 'aerobic'
    s.name = 'Aérobic & fitness'
    s.save
  end
end
