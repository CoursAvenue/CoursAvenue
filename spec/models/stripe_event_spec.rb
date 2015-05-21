require 'rails_helper'
require 'stripe_mock'

RSpec.describe StripeEvent, type: :model, with_stripe: true do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it { should validate_presence_of(:stripe_event_id) }
  it { should validate_uniqueness_of(:stripe_event_id) }
  it { should validate_presence_of(:event_type) }

  let(:stripe_helper)  { StripeMock.create_test_helper }
  let(:plan)           { FactoryGirl.create(:subscriptions_plan) }
  let(:structure)      { FactoryGirl.create(:structure, :with_contact_email) }
  let(:token)          { stripe_helper.generate_card_token }
  let!(:subscription)  { plan.create_subscription!(structure) }
  let(:stripe_invoice) { Stripe::Invoice.upcoming(customer: structure.stripe_customer_id) }
  let(:stripe_event)   { StripeMock.mock_webhook_event('invoice.payment_succeeded', stripe_invoice.as_json) }

  before do
    subscription.charge!(token)
  end

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
    context 'when the event_type is not valid' do
      subject do
        FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id,
                           event_type:      'random.event')
      end

      it "doesn't process the event" do
        expect(subject.process!).to be_falsy
      end
    end

    context 'when the event type is valid' do
      subject { FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id) }

      context 'invoice.payment_succeeded' do
        subject do
          FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id,
                                            event_type:      'invoice.payment_succeeded')
        end

        it 'creates a new invoice' do
          expect { subject.process! }.to change { Subscriptions::Invoice.count }.by(1)
        end
      end

      context 'invoice.payment_failed' do
        subject do
          FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id,
                                            event_type:      'invoice.payment_failed')
        end

        it 'pauses the subscription' do
          subject.process!
          subscription.reload

          expect(subscription.paused?).to be_truthy
        end
      end

      context 'charge.dispute.created' do
        let(:event_type) { 'charge.dispute.created' }
        let(:charge) do
          Stripe::Charge.create({
            amount:   plan.amount * 100,
            currency: Subscription::CURRENCY,
            customer: structure.stripe_customer_id
          })
        end

        let(:stripe_event) do
          StripeMock.mock_webhook_event(event_type, {
            charge: charge.id
          })
        end

        subject do
          FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id, event_type: event_type)
        end

        it 'sends an email to the admins', with_mail: true do
          expect { subject.process! }.to change{ ActionMailer::Base.deliveries.count }.by(1)
        end

        it 'pauses the subscription' do
          subject.process!
          subscription.reload

          expect(subscription.paused?).to be_truthy
        end
      end

      context 'charge.dispute.funds_withdrawn' do
        let(:event_type) { 'charge.dispute.funds_withdrawn' }
        let(:charge) do
          Stripe::Charge.create({
            amount:   plan.amount * 100,
            currency: Subscription::CURRENCY,
            customer: structure.stripe_customer_id
          })
        end

        let(:stripe_event) do
          StripeMock.mock_webhook_event(event_type, {
            charge: charge.id
          })
        end

        subject do
          FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id, event_type: event_type)
        end

        it 'sends an email to the admins', with_mail: true do
          expect { subject.process! }.to change{ ActionMailer::Base.deliveries.count }.by(1)
        end

        it 'cancels the subscription' do
          subject.process!
          subscription.reload

          expect(subscription.canceled?).to be_truthy
        end
      end

      context 'charge.dispute.funds_reinstated' do
        let(:event_type) { 'charge.dispute.funds_reinstated' }
        let(:charge) do
          Stripe::Charge.create({
            amount:   plan.amount * 100,
            currency: Subscription::CURRENCY,
            customer: structure.stripe_customer_id
          })
        end

        let(:stripe_event) { StripeMock.mock_webhook_event(event_type, { charge: charge.id }) }

        subject do
          FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id, event_type: event_type)
        end

        it 'sends an email to the admins', with_mail: true do
          expect { subject.process! }.to change{ ActionMailer::Base.deliveries.count }.by(1)
        end

        it 'resumes the subscription' do
          subject.process!
          subscription.reload

          expect(subscription.paused?).to be_falsy
        end
      end

      context 'customer.deleted' do
        let(:event_type)   { 'customer.deleted' }
        let(:customer)     { structure.stripe_customer }
        let(:stripe_event) { StripeMock.mock_webhook_event(event_type, customer.as_json) }

        subject do
          FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id, event_type: event_type)
        end

        it 'deletes the stripe_customer_id from the structure' do
          subject.process!

          structure.reload

          expect(structure.stripe_customer).to be_nil
          expect(structure.stripe_customer_id).to be_nil
        end
      end

      context 'account.updated' do
        let(:event_type)   { 'account.updated' }
        let(:account)      { structure.stripe_managed_account }
        let(:stripe_event) { StripeMock.mock_webhook_event(event_type, account.as_json) }

        before do
          structure.create_managed_account
          structure.reload
        end

        subject do
          FactoryGirl.create(:stripe_event, stripe_event_id: stripe_event.id, event_type: event_type)
        end

        it 'updates the managed account'
      end
    end
  end
end
