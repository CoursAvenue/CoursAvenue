# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Price do
  subject {price}
  let(:price)       { FactoryGirl.build(:price) }
  let(:book_ticket) { FactoryGirl.build(:book_ticket) }

  describe '#per_course_amount' do
    it { book_ticket.per_course_amount.should eq book_ticket.amount / book_ticket.number }
  end

  context :amount do
    it 'cannot have negative price' do
      price.amount = -1
      price.valid?.should be_false
    end
  end

  context :promotion do

    it 'cannot have negative promo' do
      price.promo_amount = -1
      price.valid?.should be_false
    end

    it 'cannot have promo higher than actual price' do
      price.amount       = 10
      price.promo_amount = 20
      price.valid?.should be_false
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
