class FundingType < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: 'funding_type.cif',               order: 1 },
    { id: 2, name: 'funding_type.dif',               order: 2 },
    { id: 3, name: 'funding_type.cesu',              order: 3 },
    { id: 4, name: 'funding_type.afdas',             order: 4 },
    { id: 5, name: 'funding_type.leisure_tickets',   order: 5 },
    { id: 6, name: 'funding_type.ancv_sports_coupon',order: 6 },
    { id: 7, name: 'funding_type.holiday_vouchers',  order: 7 }
  ]

end
