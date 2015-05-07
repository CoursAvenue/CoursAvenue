require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Sponsorship, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }

  context 'associations' do
    it { should belong_to(:subscription) }
  end

  context 'validations' do
    it { should validate_uniqueness_of(:sponsored_email).scoped_to(:subscription_id) }
    it { should validate_presence_of(:sponsored_email) }
  end

  let(:structure)              { FactoryGirl.create(:structure) }
  let(:plan)                   { FactoryGirl.create(:subscriptions_plan) }
  let(:subscription)           { plan.create_subscription!(structure)}
  let(:token)                  { stripe_helper.generate_card_token }

  let(:sponsored_structure)    { FactoryGirl.create(:structure, :with_contact_email) }
  let(:sponsored_subscription) { plan.create_subscription!(sponsored_structure) }
  let(:sponsored_token)        { stripe_helper.generate_card_token }

  subject                      { FactoryGirl.create(:subscriptions_sponsorship, subscription: subscription) }

  before do
    sponsored_subscription.charge!(sponsored_token)
    subscription.charge!(token)
  end

  describe '#redeem!' do
    it 'creates new coupons' do
      expect{ subject.redeem!(sponsored_subscription) }.to change { Subscriptions::Coupon.count }.by(2)
    end

    it 'applies a coupon to the sponsor subsription' do
      next_amount = subscription.next_amount

      expect { subject.redeem!(sponsored_subscription) }.
        to change { subscription.next_amount }.from(next_amount).to(0)
    end

    it 'applies a coupon to the sponsored subsription' do
      sponsored_next_amount = sponsored_subscription.next_amount

      expect { subject.redeem!(sponsored_subscription) }.
        to change { sponsored_subscription.next_amount }.
        from(sponsored_next_amount).to( sponsored_next_amount / 2.0)
    end

    it 'sends a confirmation email to the sponsor', with_mail: true do
      expect { subject.redeem!(sponsored_subscription) }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'redeems the sponsorship' do
      subject.redeem!(sponsored_subscription)

      expect(subject.redeemed?).to be_truthy
    end
  end

  describe '#notify_sponsored' do
    let(:custom_message) { Faker::Lorem.paragraph }

    it 'sends an email to the sponsored email', with_mail: true do
      expect { subject.notify_sponsored(custom_message) }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
