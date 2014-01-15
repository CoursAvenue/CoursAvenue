class AddOtherMartialArts < ActiveRecord::Migration
  def change
    combat_arts = Subject.find 'arts-martiaux-sports-de-combat'
    combat_arts.children.create(name: "Arts martiaux autres")
  end
end
