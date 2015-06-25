FactoryGirl.define do
  factory :metro_line, :class => 'Metro::Line' do
    name 'Ligne 8'
    number '8'
    route_name 'Balard ↔ (Créteil) Pointe du Lac'
  end

end
