class Audience < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, short_name: 'Kid' ,    name: 'audience.kid',    order: 1 },
    { id: 2, short_name: 'Adult' ,  name: 'audience.adult',  order: 2 },
    { id: 3, short_name: 'Senior' , name: 'audience.senior', order: 3 }
  ]
  enum_accessor :short_name
end
