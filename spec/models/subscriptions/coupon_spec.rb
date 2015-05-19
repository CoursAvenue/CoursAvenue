require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Coupon, type: :model, with_stripe: true do
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
    context "when there's no coupon" do
      before { subject.stripe_coupon_id = nil; subject.save }

      it 'returns nil' do
        expect(subject.delete_stripe_coupon!).to be_nil
      end
    end

    context "when there's a coupon" do
      it 'set the stripe_coupon_id to nil' do
        subject.delete_stripe_coupon!

        expect(subject.stripe_coupon_id).to be_nil
      end

      it 'deletes the coupon on Stripe' do
        stripe_coupon_id = subject.stripe_coupon_id
        subject.delete_stripe_coupon!

        expect { Stripe::Coupon.retrieve(stripe_coupon_id) }.
          to raise_error(Stripe::InvalidRequestError, /No such coupon/)
      end
    end
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
