# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Price do
  subject {price}
  let(:price)       { FactoryGirl.build(:price) }
  let(:book_ticket) { FactoryGirl.build(:book_ticket) }

  describe '#per_course_amount' do
    it { expect(book_ticket.per_course_amount).to eq book_ticket.amount / book_ticket.number }
  end

  context :amount do
    it 'cannot have negative price' do
      price.amount = -1
      expect(price.valid?).to eq false
    end
  end

  context :promotion do

    it 'cannot have negative promo' do
      price.promo_amount = -1
      expect(price.valid?).to eq false
    end

    it 'cannot have promo higher than actual price' do
      price.amount       = 10
      price.promo_amount = 20
      expect(price.valid?).to eq false
    end

    describe '#has_promo?' do
      it 'has promo' do
        price.promo_amount = nil
        expect(price.has_promo?).to eq false
      end

      it 'does not have promo' do
        price.promo_amount = 22
        expect(price.has_promo?).to eq true
      end
    end
  end

  context 'nb_courses is not defined' do
    it 'returns 1' do
      price.nb_courses = nil
      expect(price.nb_courses).to eq 1
    end
  end

  context 'nb_courses is defined' do
    it 'returns 1' do
      price.nb_courses = 23
      expect(price.nb_courses).to eq 23
    end
  end
end
