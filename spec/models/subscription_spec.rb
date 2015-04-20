require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscription, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  subject             { FactoryGirl.create(:subscription) }

  it { should validate_uniqueness_of(:stripe_subscription_id) }
  it { should belong_to(:structure) }
  it { should belong_to(:plan).class_name('Subscriptions::Plan').with_foreign_key('subscriptions_plan_id') }
  it { should have_many(:invoices).class_name('Subscriptions::Invoice') }

  describe '#stripe_subscription' do
    context "when there isn't a stripe_subscription_id" do
      subject { FactoryGirl.create(:subscription) }
      it 'returns nil' do
        expect(subject.stripe_subscription).to be_nil
      end
    end

    context "when there's a stripe_subscription_id" do
      let(:plan)      { FactoryGirl.create(:subscriptions_plan) }
      let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }
      let(:token)     { stripe_helper.generate_card_token }

      subject { plan.create_subscription!(structure, token) }

      it 'returns a Stripe::Subscription object' do
        stripe_subscription = Stripe::Subscription

        expect(subject.stripe_subscription).to be_a(stripe_subscription)
      end
    end
  end

  describe '#canceled?' do
    let(:plan)      { FactoryGirl.create(:subscriptions_plan) }
    let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }

    context 'when not canceled' do
      let(:token) { stripe_helper.generate_card_token }
      subject     { plan.create_subscription!(structure, token) }

      it { expect(subject.canceled?).to be_falsy }
    end

    context 'when canceled' do
      subject { FactoryGirl.create(:subscription, :canceled) }
      it { expect(subject.canceled?).to be_truthy }
    end
  end

  describe '#cancel!' do
    let(:plan)      { FactoryGirl.create(:subscriptions_plan) }
    let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }
    let(:token)     { stripe_helper.generate_card_token }

    subject         { plan.create_subscription!(structure, token) }

    it 'cancels the subscription' do
      subject.cancel!

      expect(subject.canceled?).to be_truthy
    end

    context 'when we cancel at the end of the period' do
      it 'sets the expiration date to the end of the current period' do
        stripe_subscription = subject.cancel!

        expect(subject.expires_at).to_not be_nil
        expect(subject.expires_at).to eq(Time.at(stripe_subscription.current_period_end))
      end

      it 'delays the cancelation' do
        canceled_subscription = subject.cancel!

        expect(canceled_subscription.status).to eq('active')
        expect(canceled_subscription.cancel_at_period_end).to be_truthy
      end
    end

    context 'when we cancel immediately' do
      it 'cancels immediately when the flag is given' do
        canceled_subscription = subject.cancel!(at_period_end: false)

        expect(canceled_subscription.status).to eq('canceled')
        expect(canceled_subscription.cancel_at_period_end).to be_falsy
      end

      it 'sets the expiration date to the cancelation date' do
        canceled_subscription = subject.cancel!(at_period_end: false)

        expect(subject.expires_at).to_not be_nil
        expect(subject.expires_at).to eq(subject.canceled_at)
      end
    end

    context "when there's a trial period" do
      let(:plan) { FactoryGirl.create(:subscriptions_plan, :with_trial_period) }

      it "doesn't do anything" do
        subscription = subject.cancel!

        expect(subscription.status).to eq('trialing')
        expect(subscription.cancel_at_period_end).to be_truthy
      end
    end
  end

  describe '#change_plan!' do
    let!(:plan)       { FactoryGirl.create(:subscriptions_plan) }
    let!(:other_plan) { FactoryGirl.create(:subscriptions_plan) }
    let(:structure)   { FactoryGirl.create(:structure, :with_contact_email) }
    let(:token)       { stripe_helper.generate_card_token }
    subject           { plan.create_subscription!(structure, token) }

    it 'does nothing if the new plan is the current plan' do
      subject.change_plan!(plan)

      expect(subject.plan).to                        eq(plan)
      expect(subject.stripe_subscription.plan.id).to eq(plan.stripe_plan_id)
    end

    it 'changes associated plan' do
      stripe_subscription = subject.stripe_subscription
      subject.change_plan!(other_plan)

      subject.reload
      stripe_subscription.refresh

      expect(subject.plan).to eq(other_plan)
      expect(stripe_subscription.plan.id).to eq(other_plan.stripe_plan_id)
    end
  end

  describe '#current_period_end' do
    context "when there isn't a stripe_subscription_id" do
      subject { FactoryGirl.create(:subscription) }

      it 'returns nil' do
        expect(subject.current_period_end).to be_nil
      end
    end

    context "when there's a stripe_subscription_id" do
      let!(:plan)       { FactoryGirl.create(:subscriptions_plan) }
      let(:structure)   { FactoryGirl.create(:structure, :with_contact_email) }
      let(:token)       { stripe_helper.generate_card_token }
      subject           { plan.create_subscription!(structure, token) }

      it 'returns the current period end' do
        expect(subject.current_period_end).to_not be_nil
      end
    end
  end

  describe '#next_amount' do
    context "when there isn't a stripe_subscription_id" do
      subject { FactoryGirl.create(:subscription) }

      it 'returns nil' do
        expect(subject.next_amount).to be_nil
      end
    end

    context "when there's a stripe_subscription_id" do
      let!(:plan)       { FactoryGirl.create(:subscriptions_plan) }
      let(:structure)   { FactoryGirl.create(:structure, :with_contact_email) }
      let(:token)       { stripe_helper.generate_card_token }
      subject           { plan.create_subscription!(structure, token) }

      context 'with a coupon code' do
        let(:coupon_code) { FactoryGirl.create(:subscriptions_coupon) }

        it 'returns the next amount' do
          next_amount = plan.amount - coupon_code.amount

          expect(subject.next_amount).to eq(next_amount)
        end
      end

      context 'without a coupon code' do
        it 'returns the next amount' do
          next_amount = plan.amount

          expect(subject.next_amount).to eq(next_amount)
        end
      end
    end
  end

  describe '#apply_coupon' do
    let(:coupon) { FactoryGirl.create(:subscriptions_coupon) }

    context 'when the coupon is valid' do
      it 'applies the coupon' do
        new_amount = subject.next_amount - coupon.amount

        expect(subject.apply_coupon(coupon)).to eq(new_amount)
      end
    end

    context 'when the coupon is not valid' do
      it 'returns nil' do
        expect(subject).apply_coupon(coupon).to be_nil
      end
    end

  end

  describe '#has_coupon' do
    context 'the subscription has a coupon' do
      let(:coupon) { FactoryGirl.create(:subscriptions_coupon) }
      before       { subject.apply_coupon(coupon) }

      it { expect(subject.has_coupon?).to be_truthy }
    end

    context "the subscription doesn't have a coupon" do
      it { expect(subject.has_coupon?).to be_falsy }
    end
  end
end
