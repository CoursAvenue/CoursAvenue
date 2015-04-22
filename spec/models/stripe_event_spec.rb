require 'rails_helper'
require 'stripe_mock'

RSpec.describe StripeEvent, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it { should validate_presence_of(:stripe_event_id) }
  it { should validate_uniqueness_of(:stripe_event_id) }

  let!(:stripe_event) { StripeMock.mock_webhook_event('invoice.created') }

  describe '.processed?' do
    context "when it hasn't been processed" do
      it { expect(StripeEvent.processed?(stripe_event)).to be_falsy }
    end

    context 'when it has already been processed' do
      before { StripeEvent.process!(stripe_event) }
      it { expect(StripeEvent.processed?(stripe_event)).to be_truthy }
    end
  end

  describe '.process!' do
    context "when it hasn't been processed" do
      it 'processes the event' do
        StripeEvent.process!(stripe_event)

        expect(StripeEvent.processed?(stripe_event)).to be_truthy
      end

      it 'creates a new StripeEvent' do
        event = StripeEvent.process!(stripe_event)

        expect(event).to_not be_nil
        expect(event).to be_a(StripeEvent)
      end
    end

    context 'when it has alredy bee processed' do
      before { StripeEvent.process!(stripe_event) }

      it 'does nothing' do
        expect(StripeEvent.process!(stripe_event)).to be_falsy
      end
    end
  end

  describe '#stripe_event' do
    subject { FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id) }

    it 'returns the Stripe event object' do
      expect(subject.stripe_event).to be_a(Stripe::Event)
    end
  end

end
