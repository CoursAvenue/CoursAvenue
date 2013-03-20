require 'spec_helper'

describe Place do
  context :create
    it 'should create a default room when creating place' do
      place = FactoryGirl.build(:place)
      place.rooms.length.should_eq 1
    end
  end
end
