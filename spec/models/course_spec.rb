# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Course do
  subject(:course) { FactoryGirl.create(:course) }

  it { should be_valid }
  it { should have_many(:indexable_cards) }

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

  describe '#activate' do
    before(:each) do
      subject.active = false
      subject.save
    end

    context 'without planning' do
      context 'without prices' do

        before do
          subject.activate!
        end

        it 'fails' do
          expect(subject.active).to eq false
        end

        it 'has validation errors' do
          expect(subject.errors[:price_group].length).to eq 1
          expect(subject.errors[:plannings].length).to   eq 1
        end
      end

      context 'with prices' do
        let(:price_group) { FactoryGirl.build(:price_group) }

        before do
          subject.price_group = price_group
          subject.save
          subject.activate!
        end

        it 'fails' do
          expect(subject.active).to eq false
        end

        it 'has some validation errors' do
          expect(subject.errors[:price_group].length).to eq 0
          expect(subject.errors[:plannings].length).to   eq 1
        end

      end
    end

    context 'without prices' do
      let (:planning)    { FactoryGirl.create(:planning) }

      before do
        subject.plannings << planning
        subject.save

        subject.activate!
      end

      it 'fails' do
        expect(subject.active).to eq false
      end

      it 'has some validation errors' do
        expect(subject.errors[:price_group].length).to eq 1
        expect(subject.errors[:plannings].length).to   eq 0
      end
    end

    context 'with prices and plannings' do
      let (:planning)    { FactoryGirl.create(:planning) }
      let (:price_group) { FactoryGirl.build(:price_group) }

      before do
        price_group.structure = subject.structure
        price_group.save

        subject.plannings << planning
        subject.price_group = price_group
        subject.save

        subject.activate!
      end

      it 'activates' do
        expect(subject.active).to eq true
      end

      it 'is valid' do
        expect(subject.errors[:plannings].length).to eq 0
        expect(subject.errors[:price_group].length).to eq 0
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
