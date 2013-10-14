# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Place do
  let(:place)     { FactoryGirl.create(:place) }
  let(:structure) { place.structure }
  subject {place}

  it { should be_valid }

  it { place.location.to_gmap_json[:lat].should eq place.location.latitude }
  it { place.location.to_gmap_json[:lng].should eq place.location.longitude }

end
