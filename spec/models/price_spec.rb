# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Price do
  subject {price}
  let(:price)             { FactoryGirl.build(:price) }
  let(:individual_price)  { FactoryGirl.build(:individual_price) }
  let(:annual_price)      { FactoryGirl.build(:annual_price) }

  describe '#per_course_amount' do
    it { price.per_course_amount.should eq price.amount / price.nb_courses }
  end

  describe '#individual_course?' do
    it 'is an individual_course' do
      individual_price.individual_course?.should be_true
    end

    it 'is not an individual_course' do
      annual_price.individual_course?.should be_false
    end
  end

  describe '#has_promo?' do
    it 'has promo' do
      price.promo_amount = nil
      price.has_promo?.should be_false
    end

    it 'does not have promo' do
      price.promo_amount = 22
      price.has_promo?.should be_true
    end
  end

  context 'nb_courses is not defined' do
    it 'returns 1' do
      price.nb_courses = nil
      price.nb_courses.should eq 1
    end
  end

  context 'nb_courses is defined' do
    it 'returns 1' do
      price.nb_courses = 23
      price.nb_courses.should eq 23
    end
  end
end
