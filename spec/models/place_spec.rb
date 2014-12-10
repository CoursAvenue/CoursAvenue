# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Place do
  let(:place)     { FactoryGirl.create(:place) }
  let(:structure) { place.structure }
  subject {place}

  it { should be_valid }

  it { expect(place.to_gmap_json[:lat]).to eq(place.latitude) }
  it { expect(place.to_gmap_json[:lng]).to eq(place.longitude) }

  context 'destroy' do
    it 'destroys associate plannings' do
    end
  end

end
