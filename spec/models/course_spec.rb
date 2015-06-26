# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Course do
  subject(:course) { FactoryGirl.create(:course) }

  it { should be_valid }

  describe '#has_promotion?' do
    it { expect(subject.has_promotion?).to eq false }

    context 'with promotion' do
      let(:price)       { FactoryGirl.create(:price_subscription, amount: 200) }
      let(:price_group) { FactoryGirl.build(:price_group) }

      before do
        price.promo_amount = 10
        price.save

        price_group.prices    = [price]
        price_group.structure = subject.structure
        price_group.save

        subject.price_group = price_group
        subject.save
      end

      it 'has a promotion when the amount is set' do
        expect(subject.has_promotion?).to eq true
      end
    end
  end

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
