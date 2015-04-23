require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Plan, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  subject             { FactoryGirl.create(:subscriptions_plan) }
  let(:stripe_helper) { StripeMock.create_test_helper }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:interval) }

  it { should have_many(:subscriptions) }

  describe '.create' do
    let(:trial_period) { (1..30).to_a.sample }

    it 'creates a stripe plan' do
      plan = FactoryGirl.create(:subscriptions_plan)
      stripe_plan = Stripe::Plan.retrieve(plan.stripe_plan_id)

      expect(plan.stripe_plan).to be_a (Stripe::Plan)
    end

    it 'creates a plan with a trial period if one is given' do
      plan = FactoryGirl.create(:subscriptions_plan, trial_period_days: trial_period)
      stripe_plan = Stripe::Plan.retrieve(plan.stripe_plan_id)

      expect(stripe_plan).to be_a (Stripe::Plan)
      expect(stripe_plan.trial_period_days).to eq(trial_period)
    end
  end

  describe '#stripe_plan' do
    context 'when stripe_plan_id is not defined' do
      subject do
        plan = FactoryGirl.build(:subscriptions_plan, :empty)
        plan.save(validate: false)
        plan
      end

      it 'returns nil' do
        expect(subject.stripe_plan).to be_nil
      end
    end

    context 'when the stripe_plan_id is defined' do
      it 'returns a Stripe::Plan object' do
        stripe_plan = Stripe::Plan

        expect(subject.stripe_plan).to be_a(stripe_plan)
      end
    end
  end

  describe '#update_stripe_plan!' do
    let(:new_plan_name) { Faker::Name.name }

    it "updates the plan's name on Stripe" do
      current_plan_name = subject.name

      subject.name = new_plan_name
      subject.save

      expect { subject.update_stripe_plan! }.
        to change { subject.stripe_plan.name }.from(current_plan_name).to(new_plan_name)
    end

    it 'returns the Stripe::Plan' do
      expect(subject.update_stripe_plan!).to be_a(Stripe::Plan)
    end
  end

  describe '#delete_stripe_plan!' do
    context "when there's no plan" do
      subject do
        plan = FactoryGirl.build(:subscriptions_plan, :empty)
        plan.save(validate: false)
        plan
      end

      it 'returns nil' do
        expect(subject.delete_stripe_plan!).to be_nil
      end
    end

    context "when there's a plan" do

      it 'sets the stripe_plan_id to nil' do
        subject.delete_stripe_plan!

        expect(subject.stripe_plan_id).to eq(nil)
      end

      it 'deletes the plan on Stripe' do
        stripe_plan_id = subject.stripe_plan_id
        subject.delete_stripe_plan!

        expect { Stripe::Plan.retrieve(stripe_plan_id) }.
          to raise_error(Stripe::InvalidRequestError, /No such plan/)
      end
    end

  end

  describe '#create_subscription!' do
    let(:token)     { stripe_helper.generate_card_token({}) }
    let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }
    let(:coupon)    { FactoryGirl.create(:subscriptions_coupon) }

    context "when there isn't a Stripe customer yet" do
      it "doens't create a new subsription" do
        subscription = subject.create_subscription!(structure)

        expect(subscription).to be_nil
      end

      it 'creates a new customer if the card token is given' do
        subject.create_subscription!(structure, token)

        expect(structure.stripe_customer).to_not be_nil
        expect(structure.stripe_customer).to be_a(Stripe::Customer)
      end

      it 'creates a new subscription if the card token is given' do
        subscription = subject.create_subscription!(structure, token)

        expect(subscription).to_not                 be_nil
        expect(subscription).to                     be_a(Subscription)
        expect(subscription.stripe_subscription).to be_a(Stripe::Subscription)
      end

      it 'creates a new subscription with a coupon if the coupon is given' do
        subscription = subject.create_subscription!(structure, token, coupon.code)

        expect(subscription).to_not                 be_nil
        expect(subscription).to                     be_a(Subscription)
        expect(subscription.stripe_subscription).to be_a(Stripe::Subscription)
        expect(subscription.has_coupon?).to         be_truthy
      end
    end

    context "when there is a stripe customer" do
      before { structure.create_stripe_customer(token) }

      it 'creates a new subscription' do
        subscription = subject.create_subscription!(structure)

        expect(subscription).to_not                 be_nil
        expect(subscription).to                     be_a(Subscription)
        expect(subscription.stripe_subscription).to be_a(Stripe::Subscription)
      end

      it 'creates a new subscription with a coupon if the coupon is given' do
        subscription = subject.create_subscription!(structure, nil, coupon.code)

        expect(subscription).to_not                 be_nil
        expect(subscription).to                     be_a(Subscription)
        expect(subscription.stripe_subscription).to be_a(Stripe::Subscription)
        expect(subscription.has_coupon?).to         be_truthy
      end
    end

    context "when there's a coupon code" do
      let(:coupon) { FactoryGirl.create(:subscriptions_coupon) }
      before { structure.create_stripe_customer(token) }

      it 'creates a new subscription and applies the coupon code' do
        subscription = subject.create_subscription!(structure, nil, coupon.code)

        expect(subscription).to_not be_nil
        expect(subscription.has_coupon?).to be_truthy
      end
    end
  end
end
