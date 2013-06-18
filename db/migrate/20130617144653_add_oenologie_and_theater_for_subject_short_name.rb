# encoding: utf-8
class AddOenologieAndTheaterForSubjectShortName < ActiveRecord::Migration
  def up
    cooking              = Subject.where(name: 'Cuisine / Œnologie').first
    cooking.update_column :short_name, 'Cuisine / Œnologie'

    spectacle            = Subject.where(name: 'Arts du spectacle').first
    spectacle.update_column :short_name, 'Spectacle / Théâtre'
    spectacle.update_column :name, 'Spectacle / Théâtre'
  end

  def down
    cooking              = Subject.where(name: 'Cuisine / Œnologie').first
    cooking.update_column :short_name, 'Cuisine'

    spectacle            = Subject.where(name: 'Spectacle / Théâtre').first
    spectacle.update_column :short_name, 'Spectacle'
    spectacle.update_column :name, 'Arts du spectacle'
  end
end
