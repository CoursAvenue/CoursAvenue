require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Plan, type: :model do
  subject { FactoryGirl.create(:subscriptions_plan, :gold_plan) }

  it { should validate_uniqueness_of(:stripe_plan_id) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:interval) }
  it { should have_many(:subscriptions) }

  describe '#stripe_plan' do
    it 'returns a Stripe::Plan object' do
      stripe_plan = Stripe::Plan

      expect(subject.stripe_plan).to be_a(stripe_plan)
    end
  end

  describe '#create_subscription!' do
    context 'when stripe_plan_id is not defined' do
      subject { FactoryGirl.create(:subscriptions_plan, :empty) }

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
end
