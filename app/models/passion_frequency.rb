class PassionFrequency < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'passions.frequencies.everyday' },
    { id: 2, name: 'passions.frequencies.two_to_five_a_week' },
    { id: 3, name: 'passions.frequencies.once_a_week' },
    { id: 4, name: 'passions.frequencies.once_a_month' },
    { id: 5, name: 'passions.frequencies.less_than_10_times_a_year' }
  ]
end
