# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Course do
  subject(:course) { FactoryGirl.create(:course) }

  it { should be_valid }
  it { should have_many(:indexable_cards) }

  context 'lesson' do
    subject(:lesson) { FactoryGirl.create(:lesson) }

    it 'is a lesson' do
      expect(subject.is_lesson?).to eq true
      expect(subject.underscore_name).to eq 'lesson'
      expect(subject.class.underscore_name).to eq 'lesson'
    end

    it 'is not a training' do
      expect(subject.is_training?).to eq false
    end

    it 'never expires' do
      expect(subject.expired?).to be_falsy
    end
  end

  context 'training' do
    subject(:training) { FactoryGirl.create(:training) }

    it 'is a training' do
      expect(subject.is_lesson?).to eq false
    end

    it 'is not a lesson' do
      expect(subject.is_training?).to eq true
    end
  end

  context 'friendly_id' do
    let (:initial_slug) { subject.slug }

    it 'has a slug' do
      expect(subject.slug).to_not be_nil
    end

    it 'keeps the same slug' do
      subject.slug += ' new slug'
      subject.save

      expect(subject.slug).to eq initial_slug
    end
  end
end
