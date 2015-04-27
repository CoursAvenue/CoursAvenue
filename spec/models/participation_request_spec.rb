# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'stripe_mock'

# TODO: Prevent the sending of emails.
describe ParticipationRequest do

  subject { FactoryGirl.create(:participation_request) }

  describe '#past?' do
    it 'returns true' do
      subject.date = Date.yesterday
      expect(subject.past?).to eq true
    end

    it 'returns false' do
      subject.date = Date.tomorrow
      expect(subject.past?).to eq false
    end
  end

  describe '#stripe_charge' do
    before(:all) { StripeMock.start }
    after(:all)  { StripeMock.stop }

    let(:stripe_helper) { StripeMock.create_test_helper }

    context "when there isn't a stripe_charge_id" do
      it 'return nil' do
        expect(subject.stripe_charge).to be_nil
      end
    end

    context "when there's a stripe_charge_id" do
      before do
        source        = stripe_helper.generate_card_token
        stripe_charge = Stripe::Charge.create({
          amount:   (5..30).to_a.sample * 100,
          currency: Subscription::CURRENCY,
          source:   source
        })
        subject.stripe_charge_id = stripe_charge.id

        subject.save
      end

      it 'returns the Stripe::Charge' do
        expect(subject.stripe_charge).to_not be_nil
        expect(subject.stripe_charge).to be_a(Stripe::Charge)
      end
    end
  end
end
