# encoding: utf-8


## Audiences
Audience.delete_all
Audience.create(name: 'audience.kid', order: 1)
Audience.create(name: 'audience.teenage', order: 2)
Audience.create(name: 'audience.adult', order: 3)
Audience.create(name: 'audience.senior', order: 4)


## Levels
Level.delete_all
Lebel.create(name: 'level.all', order: 0)
Lebel.create(name: 'level.initiation', order: 1)
Lebel.create(name: 'level.beginner', order: 2)
Lebel.create(name: 'level.intermediate', order: 3)
Lebel.create(name: 'level.average', order: 4)
Lebel.create(name: 'level.advanced', order: 5)
