FactoryGirl.define do
  factory :ratp_line, :class => 'Ratp::Line' do
    name 'Ligne 8'
    number '8'
    route_name 'Balard ↔ (Créteil) Pointe du Lac'
    line_type { RATP::Line::LINE_TYPE.sample }
  end

end
