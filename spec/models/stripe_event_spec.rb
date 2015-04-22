require 'rails_helper'
require 'stripe_mock'

RSpec.describe StripeEvent, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it { should validate_presence_of(:stripe_event_id) }
  it { should validate_uniqueness_of(:stripe_event_id) }
  it { should validate_presence_of(:event_type) }

  let!(:stripe_event) { StripeMock.mock_webhook_event('invoice.created') }

  describe '#stripe_event' do
    subject { FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id) }

    it 'returns the Stripe event object' do
      expect(subject.stripe_event).to be_a(Stripe::Event)
    end
  end

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
        expect { StripeEvent.process!(stripe_event) }.
          to change { StripeEvent.count }.by(1)
      end
    end

    context 'when it has alredy bee processed' do
      before { StripeEvent.process!(stripe_event) }

      it 'does nothing' do
        expect(StripeEvent.process!(stripe_event)).to be_falsy
      end
    end
  end

  describe '#process!' do
    context 'when the event type is valid' do
      subject { FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id) }

      it 'processes the event' do
        expect(subject.process!).to be_truthy
      end
    end

    context 'when the event_type is not valid' do
      subject { FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id, event_type: '') }

      it "doesn't process the event" do
        expect(subject.process!).to be_falsy
      end
    end
  end
end
