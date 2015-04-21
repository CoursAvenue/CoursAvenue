require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Coupon, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:duration) }
  it { should validate_inclusion_of(:duration).in_array(Subscriptions::Coupon::DURATIONS.keys.map(&:to_s)) }
  it { should validate_presence_of(:amount) }
  it { should have_many(:subscriptions) }

  subject { FactoryGirl.create(:subscriptions_coupon) }

  describe '#stripe_coupon' do
    context 'when stripe_coupon_id is not defined' do
      subject { FactoryGirl.create(:subscriptions_coupon) }
      before  { subject.stripe_coupon_id = nil; subject.save }

      it 'returns nil' do
        expect(subject.stripe_coupon).to be_nil
      end
    end

    context 'when the stripe_coupon_id is defined' do
      it 'returns a Stripe::Coupon object' do
        stripe_coupon = Stripe::Coupon

        expect(subject.stripe_coupon).to be_a(stripe_coupon)
      end
    end
  end

  describe '#still_valid?' do
    context "when it's valid" do
      it { expect(subject.still_valid?).to be_truthy }
    end

    context "when it's not valid" do
      subject { FactoryGirl.create(:subscriptions_coupon, :empty) }
      before  { subject.stripe_coupon_id = nil; subject.save }

      it { expect(subject.still_valid?).to be_falsy }
    end
  end

  describe '#delete_stripe_coupon!' do
    it 'deletes the plan on stripe'
  end

  describe '#code' do
    context 'when stripe_coupon_id is not defined' do
      subject { FactoryGirl.create(:subscriptions_coupon) }
      before  { subject.stripe_coupon_id = nil; subject.save }

      it 'returns nil' do
        expect(subject.code).to be_nil
      end
    end

    context 'when the stripe_coupon_id is defined' do
      it 'returns a Stripe::Coupon object' do
        expect(subject.code).to eq(subject.stripe_coupon_id)
      end
    end
  end
end
