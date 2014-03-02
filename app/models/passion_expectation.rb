class PassionExpectation < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'passions.needs.offers' },
    { id: 2, name: 'passions.needs.better_time_slots' },
    { id: 3, name: 'passions.needs.closest' },
    { id: 4, name: 'passions.needs.new' },
    { id: 5, name: 'passions.needs.events' },
    { id: 6, name: 'passions.needs.partner' },
    { id: 7, name: 'passions.needs.share_passions' },
    { id: 8, name: 'passions.needs.nothing' },
    { id: 9, name: 'passions.needs.stop' }
  ]
end
