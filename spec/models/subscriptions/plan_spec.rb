require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Plan, type: :model do
  after(:context) do
    Stripe::Customer.all(limit: 100).each(&:delete)
    Stripe::Plan.all(limit: 100).each(&:delete)
  end

  subject             { FactoryGirl.create(:subscriptions_plan, :gold_plan) }
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
end
