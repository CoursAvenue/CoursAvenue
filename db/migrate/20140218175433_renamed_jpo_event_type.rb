class RenamedJpoEventType < ActiveRecord::Migration
  def up
    Course::Open.where{event_type == 'Atelier collectif'}.update_all(event_type: 'Cours collectif')
  end

  def down
  end
end
