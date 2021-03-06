class Level < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 0, short_name: 'All',          name: 'level.all',          order: 0},
    { id: 1, short_name: 'Beginner',     name: 'level.beginner',     order: 1},
    { id: 2, short_name: 'Intermediate', name: 'level.intermediate', order: 2},
    { id: 3, short_name: 'Confirmed',    name: 'level.confirmed',    order: 3},
    { id: 4, short_name: 'Professional', name: 'level.professional', order: 4}
  ]
  enum_accessor :short_name
end
