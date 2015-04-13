require 'rails_helper'

# TODO: Create the stripe objects at the beginning.
RSpec.describe Subscription, type: :model do
  subject { FactoryGirl.create(:subscription) }

  it { should validate_uniqueness_of(:stripe_subscription_id) }
  it { should belong_to(:structure) }
  it { should have_one(:plan).class_name('Subscription::Plan') }
  it { should have_many(:invoices).class_name('Subscription::Invoice') }

  describe '#stripe_subscription' do
    it 'returns a Stripe::Subscription object' do
      stripe_subscription = Stripe::Subscription

      expect(subject.stripe_subscription).to eq(stripe_subscription)
    end
  end

  describe '#canceled?' do
    context 'when not canceled' do
      it { expect(subject.canceled?).to be_falsy }
    end

    context 'when canceled' do
      subject { FactoryGirl.create(:subscription, :canceled) }
      it { expect(subject.canceled?).to be_truthy }
    end
  end

  describe '#cancel!' do
    it 'cancels the subscription' do
      subject.cancel!

      expect(subject.canceled?).to be_truthy
    end

    it 'delays the cancelation until the period end by default' do
      subject.cancel!

      expect(subject.stripe_subscription.cancel_at_period_end).to be_truthy
      expect(subject.stripe_subscription.canceled_at).to be_nil
    end

    it 'cancels immediately when the flag is given' do
      subject.cancel!(at_period_end: false)

      expect(subject.stripe_subscription.cancel_at_period_end).to be_falsy
      expect(subject.stripe_subscription.canceled_at).to_not be_nil
    end
  end

  describe '#change_plan!' do
    let(:current_plan) { subject.plan }
    let(:new_plan)     { FactoryGirl.create(:subscription_plan) }

    it 'does nothing if the new plan is the current plan' do
      subject.change_plan!(current_plan)

      expect(subject.plan).to eq(current_plan)
    end

    it 'changes associated plan' do
      subject.change_plan!(new_plan)

      expect(subject.plan).to_not eq(current_plan)
      expect(subject.plan).to     eq(new_plan)
    end
  end
end
