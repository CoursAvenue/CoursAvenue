require 'rails_helper'
require 'stripe_mock'

describe StripeWebhookController do

  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }

  let(:plan)          { FactoryGirl.create(:subscriptions_plan) }
  let(:structure)     { FactoryGirl.create(:structure, :with_contact_email) }
  let(:token)         { stripe_helper.generate_card_token }
  let!(:subscription) { plan.create_subscription!(structure, token) }

  describe '#create' do
    context 'when receiving a `invoice.created` event' do
      let(:invoice) { Stripe::Invoice.upcoming(customer: structure.stripe_customer_id) }
      let!(:event)  { StripeMock.mock_webhook_event('invoice.created', invoice.as_json) }

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
    end
  end
end
