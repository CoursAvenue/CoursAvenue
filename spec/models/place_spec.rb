# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Place do
  let(:place)     { FactoryGirl.create(:place) }
  let(:structure) { place.structure }
  subject {place}

  it { should be_valid }

  it { place.to_gmap_json[:lat].should eq place.latitude }
  it { place.to_gmap_json[:lng].should eq place.longitude }

  context 'destroy' do
    it 'destroys associate plannings' do
    end
  end

end
