require 'stripe_mock'
require 'rails_helper'

RSpec.describe Subscription, type: :model, with_stripe: true do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  subject             { FactoryGirl.create(:subscription) }

  context 'associations' do
    it { should belong_to(:structure) }
    it { should belong_to(:plan).class_name('Subscriptions::Plan').with_foreign_key('subscriptions_plan_id') }
    it { should belong_to(:coupon).class_name('Subscriptions::Coupon').with_foreign_key('subscriptions_coupon_id') }
    it { should have_many(:invoices).class_name('Subscriptions::Invoice') }
    it { should have_many(:sponsorships).class_name('Subscriptions::Sponsorship') }
  end

  context 'validation' do
    it { should validate_uniqueness_of(:stripe_subscription_id).allow_blank }
  end

  describe '#stripe_subscription' do
    context "when there isn't a stripe_subscription_id" do
      subject { FactoryGirl.create(:subscription) }
      it 'returns nil' do
        expect(subject.stripe_subscription).to be_nil
      end
    end

    context "when there's a stripe_subscription_id" do
      let(:plan)      { FactoryGirl.create(:subscriptions_plan, :monthly) }
      let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }
      let(:token)     { stripe_helper.generate_card_token }

      subject { plan.create_subscription!(structure) }

      before do
        subject.charge!(token)
      end

      it 'returns a Stripe::Subscription object' do
        stripe_subscription = Stripe::Subscription

        expect(subject.stripe_subscription).to be_a(stripe_subscription)
      end
    end
  end

  describe '#canceled?' do
    let(:plan)      { FactoryGirl.create(:subscriptions_plan, :monthly) }
    let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }

    context 'when not canceled' do
      let(:token) { stripe_helper.generate_card_token }
      subject     { plan.create_subscription!(structure) }

      before do
        subject.charge!(token)
      end

    end

    context 'when canceled' do
      subject { FactoryGirl.create(:subscription, :canceled) }
      it { expect(subject.canceled?).to be_truthy }
    end
  end

  describe '#active?' do
    let(:plan)      { FactoryGirl.create(:subscriptions_plan, :monthly) }
    let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }

    context 'when canceled' do
      subject { FactoryGirl.create(:subscription, :canceled) }

      it { expect(subject.active?).to be_falsy }
    end

    context 'when in trial' do
      subject { FactoryGirl.create(:subscription, structure: structure, trial_ends_at: 1.day.from_now) }

      it { expect(subject.active?).to be_truthy }
    end

    context 'when in trial ends' do
      subject { FactoryGirl.create(:subscription, structure: structure, trial_ends_at: 1.day.ago) }

      it { expect(subject.active?).to be_falsy }
    end

    context 'when active' do
      let(:token) { stripe_helper.generate_card_token }
      subject     { plan.create_subscription!(structure) }

      before do
        subject.charge!(token)
      end

      it { expect(subject.active?).to be_truthy }
    end
  end

  describe '#charge!' do
    let!(:plan)      { FactoryGirl.create(:subscriptions_plan, :monthly) }
    let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }
    let(:token)     { stripe_helper.generate_card_token }

    subject         { plan.create_subscription!(structure) }

    context "when there isn't a a stripe customer" do
      context 'without a token' do
        it "doesn't create a Stripe Subscription" do
          subject.charge!

          expect(subject.stripe_subscription).to be_nil
        end
      end

      context "with a token" do
        it 'creates a Stripe Subscription' do
          subject.charge!(token)

          expect(subject.stripe_subscription).to_not be_nil
          expect(subject.stripe_subscription).to be_a(Stripe::Subscription)
        end
      end
    end

    context "when there is a Stripe customer" do
      before do
        structure.create_stripe_customer(token)
        structure.reload
      end

      it 'creates a stripe subscription' do
        subject.charge!

        expect(subject.stripe_subscription).to_not be_nil
        expect(subject.stripe_subscription).to be_a(Stripe::Subscription)
      end
    end

    context 'with a sponsorship' do
      let(:other_structure)    { FactoryGirl.create(:structure, :with_contact_email) }
      let(:other_subscription) { plan.create_subscription!(other_structure) }
      let(:other_token)        { stripe_helper.generate_card_token }
      let(:sponsorship)        {
        FactoryGirl.create(:subscriptions_sponsorship, subscription: other_subscription)
      }

      before do
        other_subscription.charge!(other_token)

        structure.sponsorship_token = sponsorship.token
        structure.save
        structure.reload
      end

      xit 'applies the half off coupon' do
        subject.charge!(token)
        coupon_amount = plan.monthly_amount / 2.0

        expect(subject.next_amount).to eq(plan.amount - coupon_amount)
      end

      xit 'applies the coupon to the sponsor' do
        subject.charge!(token)
        coupon_amount = plan.monthly_amount

        other_subscription.reload
        expect(other_subscription.next_amount).to eq(plan.amount - coupon_amount)
      end
    end
  end

  describe '#cancel!' do
    let(:plan)      { FactoryGirl.create(:subscriptions_plan) }
    let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }
    let(:token)     { stripe_helper.generate_card_token }

    subject { plan.create_subscription!(structure) }

    before do
      subject.charge!(token)
    end

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

      # it 'delays the cancelation' do
      #   canceled_subscription = subject.cancel!
      #
      #   expect(canceled_subscription.status).to eq('active')
      #   expect(canceled_subscription.cancel_at_period_end).to be_truthy
      # end
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

  describe '#pause!' do
    it 'pauses the subscription' do
      subject.pause!

      expect(subject.paused?).to be_truthy
    end
  end

  describe '#resume!' do
    subject { FactoryGirl.create(:subscription, :paused) }
    it 'resumes the subscription' do
      subject.resume!

      expect(subject.paused?).to be_falsy
    end
  end

  describe '#change_plan!' do
    let!(:plan)       { FactoryGirl.create(:subscriptions_plan) }
    let!(:other_plan) { FactoryGirl.create(:subscriptions_plan) }
    let(:structure)   { FactoryGirl.create(:structure, :with_contact_email) }
    let(:token)       { stripe_helper.generate_card_token }
    subject           { plan.create_subscription!(structure) }

    before do
      subject.charge!(token)
    end

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
      subject           { plan.create_subscription!(structure) }

      before do
        subject.charge!(token)
      end

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
      subject           { plan.create_subscription!(structure) }

      before do
        subject.charge!(token)
      end

      context 'with a coupon code' do
        let(:coupon_code) { FactoryGirl.create(:subscriptions_coupon) }

        before do
          subject.apply_coupon(coupon_code)
        end

        xit 'returns the next amount' do
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
      let!(:plan)       { FactoryGirl.create(:subscriptions_plan) }
      let(:structure)   { FactoryGirl.create(:structure, :with_contact_email) }
      let(:token)       { stripe_helper.generate_card_token }
      subject           { plan.create_subscription!(structure) }

      before do
        subject.charge!(token)
      end

      xit 'applies the coupon' do
        expect{ subject.apply_coupon(coupon) }.
          to change { subject.next_amount }.by( - coupon.amount)
      end
    end

    context 'when the coupon is not valid' do
      it 'returns nil' do
        expect(subject.apply_coupon(coupon)).to be_nil
      end
    end
  end

  describe '#has_coupon' do
    context 'the subscription has a coupon' do
      let!(:plan)     { FactoryGirl.create(:subscriptions_plan) }
      let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }
      let(:token)     { stripe_helper.generate_card_token }
      let(:coupon)    { FactoryGirl.create(:subscriptions_coupon) }
      subject         { plan.create_subscription!(structure) }

      before do
        subject.charge!(token)
        subject.apply_coupon(coupon)
      end

      it { expect(subject.has_coupon?).to be_truthy }
    end

    context "the subscription doesn't have a coupon" do
      it { expect(subject.has_coupon?).to be_falsy }
    end
  end

  describe 'in_trial?' do
    context 'when there is no `trial_ends_at`' do
      subject { FactoryGirl.create(:subscription) }

      before do
        subject.trial_ends_at = nil
        subject.save
      end

      it { expect(subject.in_trial?).to be_falsy }
    end

    context 'when the trial end is in the past or current' do
      let(:structure) { FactoryGirl.create(:structure) }
      subject { FactoryGirl.create(:subscription, structure: structure, trial_ends_at: 1.day.ago) }

      it { expect(subject.in_trial?).to be_falsy }
    end

    context 'when the trial end is in the future' do
      let(:structure) { FactoryGirl.create(:structure) }
      subject { FactoryGirl.create(:subscription, structure: structure, trial_ends_at: 1.day.from_now) }

      it { expect(subject.in_trial?).to be_truthy }
    end

    context 'when the structure is subscribed and is still in trial' do
      let(:plan)      { FactoryGirl.create(:subscriptions_plan) }
      let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }
      let(:token)     { stripe_helper.generate_card_token }

      subject         { plan.create_subscription!(structure) }

      before do
        subject.charge!(token)
      end

      it { expect(subject.in_trial?).to be_truthy }
    end
  end
end
