# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'stripe_mock'

# TODO: Prevent the sending of emails.
describe ParticipationRequest do

  it { should have_one(:invoice).class_name('ParticipationRequest::Invoice') }

  subject { FactoryGirl.create(:participation_request, :with_participants) }

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

  describe '#price' do
    context "when there's no participant" do
      subject { FactoryGirl.create(:participation_request) }

      it 'return 0' do
        expect(subject.price).to eq(0)
      end
    end

    context "when there are participant" do
      let(:price) do
        price = 0

        subject.participants.each do |participant|
          price += participant.total_price.to_i
        end

        price
      end

      it 'returns the price' do
        expect(subject.price).to eq(price)
      end
    end
  end

  context 'stripe' do

    before(:all) { StripeMock.start }
    after(:all)  { StripeMock.stop }

    let(:stripe_helper) { StripeMock.create_test_helper }

    describe '#stripe_charge' do

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

    describe '#charge!' do
      let!(:user)      { subject.user }
      let!(:structure) { subject.structure }
      let(:token)      { stripe_helper.generate_card_token }

      context "when the structure can't receive payments" do
        it "doesn't create the charge" do
          subject.charge!

          expect(subject.stripe_charge).to be_nil
        end

        it "returns nil" do
          expect(subject.charge!).to be_nil
        end
      end

      context 'when the structure can receive payments' do
        before do
          structure.create_managed_account
        end

        context "when the user doesn't have a customer account" do
          before do
            structure.create_managed_account
            allow(structure).to receive(:can_receive_payments?).and_return(true)
          end

          context "when there isn't a token" do
            it "doesn't create a stripe customer for the user" do
              subject.charge!

              expect(user.stripe_customer).to be_nil
            end

            it "doesn't create the charge" do
              subject.charge!

              expect(subject.stripe_charge).to be_nil
            end

            it "returns nil" do
              expect(subject.charge!).to be_nil
            end
          end

          context "when there's a token" do
            it 'creates a Stripe customer for the user' do
              subject.charge!(token)

              expect(user.stripe_customer).to_not be_nil
              expect(user.stripe_customer).to be_a(Stripe::Customer)
            end
          end

          context 'all of the above' do
            before do
              user.create_stripe_customer(token)
              user.reload
            end

            it 'creates a charge' do
              subject.charge!

              expect(subject.stripe_charge).to_not be_nil
            end

            it 'generates an invoice' do
              expect { subject.charge! }.to change { ParticipationRequest::Invoice.count }.by(1)
            end

            it 'sends the invoice via mail' do
              expect { subject.charge! }.to change { ActionMailer::Base.deliveries.count }.by(2)
            end

            it 'returns the charge' do
              expect(subject.charge!).to_not be_nil
              expect(subject.charge!).to be_a(Stripe::Charge)
            end
          end
        end
      end
    end
  end
end
