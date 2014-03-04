class PassionExpectation < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'passions.expectations.offers' },
    { id: 2, name: 'passions.expectations.better_time_slots' },
    { id: 3, name: 'passions.expectations.closest' },
    { id: 4, name: 'passions.expectations.new' },
    { id: 5, name: 'passions.expectations.events' },
    { id: 6, name: 'passions.expectations.partner' },
    { id: 7, name: 'passions.expectations.share_passions' },
    { id: 8, name: 'passions.expectations.nothing' },
    { id: 9, name: 'passions.expectations.stop' }
  ]
end
