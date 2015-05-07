require 'rails_helper'

RSpec.describe Subscriptions::Sponsorship, type: :model do
  context 'associations' do
    it { should belong_to(:subscription) }
  end

  context 'validations' do
    it { should validate_uniqueness_of(:sponsored_email) }
    it { should validate_presence_of(:sponsored_email) }
  end

  subject { FactoryGirl.create(:subscriptions_sponsorship) }

  describe '#consume!' do
    it 'redeems the sponsorship' do
      subject.redeem!

      expect(subject.redeemed?).to be_truthy
    end
  end
end
