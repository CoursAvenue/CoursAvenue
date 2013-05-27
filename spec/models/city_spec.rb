# -*- encoding : utf-8 -*-
require 'spec_helper'

describe City do
  subject {city}
  let(:city) { FactoryGirl.create(:city) }

  it { city.to_gmap_json[:lat].should eq city.latitude }
  it { city.to_gmap_json[:lng].should eq city.longitude }

  it 'should not generate new slug' do
    initial_slug = city.slug
    city.name += ' new_name'
    city.save
    city.slug.should be initial_slug
  end
end
