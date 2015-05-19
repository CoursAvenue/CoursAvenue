require 'rails_helper'
require 'stripe_mock'

describe StripeWebhookController, with_stripe: true do

  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }

  let(:plan)          { FactoryGirl.create(:subscriptions_plan) }
  let(:structure)     { FactoryGirl.create(:structure, :with_contact_email) }
  let(:token)         { stripe_helper.generate_card_token }
  let!(:subscription) { plan.create_subscription!(structure) }
  let(:invoice)       { Stripe::Invoice.upcoming(customer: structure.stripe_customer_id) }


  before do
    subscription.charge!(token)
  end

  describe '#create' do

    context "when there's no id" do
      it "Sends a bad_request response when there's no id" do
        post :create

        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when there's an id" do
      let!(:event)  { StripeMock.mock_webhook_event('ping') }

      it "sends a ok response when there's no id" do
        post :create, event.as_json

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when receiving a `ping` event' do
      let!(:event)  { StripeMock.mock_webhook_event('ping') }

      subject { post :create, event.as_json }

      it 'saves the event' do
        expect { subject }.to change { StripeEvent.count }.by(1)
      end
    end

    context 'when receiving a `invoice.payment_succeeded` event' do
      let!(:event)  { StripeMock.mock_webhook_event('invoice.payment_succeeded', invoice.as_json) }

      subject { post :create, event.as_json }

      context "when it hasn't been processed" do
        it 'creates a new invoice' do
          expect { subject }.to change { Subscriptions::Invoice.count }.by(1)
        end
      end

      context 'when it has been processed' do
        before { StripeEvent.process!(event) }

        it "doesn't create a new invoice" do
          expect { subject }.to_not change { Subscriptions::Invoice.count }
        end
      end

      context 'after a failed payment' do
        let(:failed_event) { StripeMock.mock_webhook_event('invoice.payment_failed', invoice.as_json) }

        before do
          post :create, failed_event.as_json
        end

        it "doesn't create a new subscription" do
          expect { subject }.to_not change { Subscriptions::Invoice.count }
        end

        it 'resumes the subscription' do
          expect { subject }.
            to change { subscription.reload; subscription.paused? }.from(true).to(false)
        end
      end
    end

    context 'when receiving a `invoice.payment_failed` event' do
      let!(:event) { StripeMock.mock_webhook_event('invoice.payment_failed', invoice.as_json) }

      subject { post :create, event.as_json }
      it 'pauses the current subscription' do
        expect { subject }.
            to change { subscription.reload; subscription.paused? }.from(false).to(true)
      end
    end
  end
end
