class Level < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, short_name: 'Initiation',   name: 'level.initiation',  order: 1},
    { id: 2, short_name: 'Beginner',     name: 'level.beginner',    order: 2},
    { id: 3, short_name: 'Intermediate', name: 'level.intermediate',order: 3},
    { id: 4, short_name: 'Confirmed',    name: 'level.confirmed',   order: 4}
  ]
  enum_accessor :short_name
end
