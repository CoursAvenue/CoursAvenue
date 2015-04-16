require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Plan, type: :model do
  after(:context) do
    Stripe::Customer.all(limit: 100).each(&:delete)
    Stripe::Plan.all(limit: 100).each(&:delete)
  end

  subject             { FactoryGirl.create(:subscriptions_plan) }
  let(:stripe_helper) { StripeMock.create_test_helper }

  it { should validate_uniqueness_of(:stripe_plan_id) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:interval) }
  it { should have_many(:subscriptions) }

  describe '#stripe_plan' do
    context 'when stripe_plan_id is not defined' do
      subject { FactoryGirl.create(:subscriptions_plan, :empty) }

      it 'returns nil' do
        expect(subject.stripe_plan).to be_nil
      end
    end

    context 'when the stripe_plan_id is defined' do
      before { stripe_helper.create_plan(id: subject.stripe_plan_id) }

      it 'returns a Stripe::Plan object' do
        stripe_plan = Stripe::Plan

        expect(subject.stripe_plan).to be_a(stripe_plan)
      end
    end
  end

  describe '#create_subscription' do
    let(:token)     { stripe_helper.generate_card_token({}) }
    let(:structure) { FactoryGirl.create(:structure, :with_contact_email) }

    before { stripe_helper.create_plan(id: subject.stripe_plan_id) }

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
    end

    context "when there is a stripe customer" do
      before { structure.create_stripe_customer(token) }

      it 'creates a new subscription' do
        subscription = subject.create_subscription!(structure)

        expect(subscription).to_not                 be_nil
        expect(subscription).to                     be_a(Subscription)
        expect(subscription.stripe_subscription).to be_a(Stripe::Subscription)
      end
    end
  end
end
