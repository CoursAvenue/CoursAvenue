# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Place do
  subject { FactoryGirl.create(:place) }

  it { should have_many(:indexable_cards) }

  it { should be_valid }

  describe '#admin' do
    it 'returns the first contact' do
      expect(subject.admin).to eq(subject.contacts.first)
    end
  end

  describe '#parisian' do
    context 'not parisian' do
      subject { FactoryGirl.create(:place, :not_parisian) }
      it { expect(subject.parisian?).to be_falsy }
    end

    context 'parisian' do
      it { expect(subject.parisian?).to be_truthy }
    end
  end

  describe '#to_gmap_json' do
    it { expect(subject.to_gmap_json[:lat]).to eq(subject.latitude) }
    it { expect(subject.to_gmap_json[:lng]).to eq(subject.longitude) }
  end

  describe '#is_home?' do
    it { expect(subject.is_home?).to be_falsy }
  end
end
