class PassionTimeSlot < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'passions.time_slots.whatever' },
    { id: 2, name: 'passions.time_slots.night' },
    { id: 3, name: 'passions.time_slots.week_end' },
    { id: 4, name: 'passions.time_slots.morning' },
  ]
end
