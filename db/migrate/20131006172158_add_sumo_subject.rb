class AddSumoSubject < ActiveRecord::Migration
  def up
    s = Subject.find 'arts-martiaux-sports-de-combat'
    s.children.create name: 'Sumo'
  end

  def down
  end
end
