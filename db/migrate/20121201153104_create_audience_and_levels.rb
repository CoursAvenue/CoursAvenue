class CreateAudienceAndLevels < ActiveRecord::Migration
  def up
    ## Audiences
    Audience.delete_all
    Audience.create(name: 'audience.kid', order: 1)
    Audience.create(name: 'audience.teenage', order: 2)
    Audience.create(name: 'audience.adult', order: 3)
    Audience.create(name: 'audience.senior', order: 4)


    ## Levels
    Level.delete_all
    Level.create(name: 'level.all', order: 0)
    Level.create(name: 'level.initiation', order: 1)
    Level.create(name: 'level.beginner', order: 2)
    Level.create(name: 'level.intermediate', order: 3)
    Level.create(name: 'level.average', order: 4)
    Level.create(name: 'level.advanced', order: 5)
    Level.create(name: 'level.confirmed', order: 6)
  end

  def down
    Audience.delete_all
    Level.delete_all
  end
end
