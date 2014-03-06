class PassionFor < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'passions.for.me' },
    { id: 2, name: 'passions.for.couple' },
    { id: 3, name: 'passions.for.parents' },
    { id: 4, name: 'passions.for.friends' },
    { id: 5, name: 'passions.for.kids' }
  ]
end
