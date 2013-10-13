class AddSumoSubject < ActiveRecord::Migration
  def up
    s = Subject.friendly.find 'arts-martiaux-sports-de-combat'
    s.children.create name: 'Sumo'
  end

  def down
  end
end
