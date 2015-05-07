require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Sponsorship, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  context 'associations' do
    it { should belong_to(:subscription) }
  end

  context 'validations' do
    it { should validate_uniqueness_of(:sponsored_email).scoped_to(:subscription_id) }
    it { should validate_presence_of(:sponsored_email) }
  end

  let(:structure)    { FactoryGirl.build_stubbed(:structure) }
  let(:subscription) { FactoryGirl.build_stubbed(:subscription, structure: structure) }
  subject            { FactoryGirl.create(:subscriptions_sponsorship, subscription: subscription) }

  describe '#consume!' do
    it 'creates a new Stripe Coupon'
    it 'applies a coupon to the subsription'

    it 'redeems the sponsorship' do
      subject.redeem!

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
