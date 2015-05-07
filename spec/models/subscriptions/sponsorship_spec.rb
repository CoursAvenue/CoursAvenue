require 'rails_helper'

RSpec.describe Subscriptions::Sponsorship, type: :model do
  context 'associations' do
    it { should belong_to(:subscription) }
  end

  context 'validations' do
    it { should validate_uniqueness_of(:sponsored_email) }
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
