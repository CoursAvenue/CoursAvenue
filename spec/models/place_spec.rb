require 'spec_helper'

describe Place do
  context :create do
    it 'should create a default room when creating place' do
      place = Place.create name: 'Test place', zip_code: 75000, street: 'super street', city: City.first
      expect(place.rooms.length).to eq 1
    end
  end
end
