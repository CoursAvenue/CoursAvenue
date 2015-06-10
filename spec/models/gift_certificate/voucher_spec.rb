require 'rails_helper'
require 'stripe_mock'

RSpec.describe GiftCertificate::Voucher, type: :model, with_stripe: true do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:token)         { stripe_helper.generate_card_token }

  subject                { FactoryGirl.create(:gift_certificate_voucher) }
  let(:gift_certificate) { subject.gift_certificate }
  let(:user)             { subject.user }
  let(:structure)        { subject.structure }

  context 'associations' do
    it { should belong_to(:gift_certificate) }
  end

  context 'delegates' do
    it { should delegate_method(:amount)     .to(:gift_certificate) }
    it { should delegate_method(:structure)  .to(:gift_certificate) }
    it { should delegate_method(:description).to(:gift_certificate) }
    it { should delegate_method(:name)       .to(:gift_certificate).with_prefix(true) }
  end

  describe 'stripe_charge' do
    context "when there's a stripe charge id" do
      it { expect(subject.stripe_charge).to be_nil }
    end

    context 'when there is a stripe charge id' do
      before do
        source        = stripe_helper.generate_card_token
        stripe_charge = Stripe::Charge.create({
          amount:   (5..30).to_a.sample * 100,
          currency: GiftCertificate::CURRENCY,
          source:   source
        })
        subject.stripe_charge_id = stripe_charge.id

        subject.save
      end

      it 'returns the stripe charge' do
        expect(subject.stripe_charge).to_not be_nil
        expect(subject.stripe_charge).to be_a(Stripe::Charge)
      end
    end
  end

  describe '#charge!' do
    context "when the structure can't receive payments" do
      before do
        allow_any_instance_of(Structure).to receive(:can_receive_payments?).and_return(:false)
      end

      it "doesn't create the charge" do
        subject.charge!

        expect(subject.stripe_charge).to be_nil
      end

      it 'returns nil' do
        expect(subject.charge!).to be_nil
      end
    end

    context 'when the structure can receive payments' do
      before do
        structure.create_managed_account
        allow_any_instance_of(Structure).to receive(:can_receive_payments?).and_return(:false)
        allow(Stripe::BalanceTransaction).to receive(:retrieve).and_return( nil )
      end

      context "when the user doesn't have a customer account" do
        context "when there isn't a token" do
          it "doesn't create a stripe customer for the user" do
            subject.charge!

            user.reload
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
          it 'creates a stripe customer for the user' do
            subject.charge!(token)

            user.reload

            expect(user.stripe_customer).to_not be_nil
          end
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

        it 'sends an email to the user and to the teacher', with_mail: true do
          expect { subject.charge! }.to change { ActionMailer::Base.deliveries.count }.by(2)
        end

        it 'returns the charge' do
          charge = subject.charge!

          expect(charge).to_not be_nil
          expect(charge).to be_a(Stripe::Charge)
        end

        # Pending test before the stripe mocking library doens't support it yet.
        # https://github.com/rebelidealist/stripe-ruby-mock/issues/158
        xit 'sets the fees' do
          charge = subject.charge!
          subject.reload

          expect(subject.fee).to_not be_nil
          expect(subject.received_amount).to_not be_nil
        end
      end
    end
  end

  describe '#charged?' do
    context "when there isn't a stripe_charge_id" do
      it { expect(subject.charged?).to be_falsy }
    end

    context 'when there is a stripe_charge_id' do
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

      it { expect(subject.charged?).to be_truthy }
    end
  end

  describe '#use!' do
    it 'changes the used flag to true' do
      expect { subject.use! }.to change { subject.used? }.from(false).to(true)
    end
  end
end
