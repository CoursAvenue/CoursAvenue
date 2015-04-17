require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Invoice, type: :model do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:plan)          { FactoryGirl.create(:subscriptions_plan) }
  let(:structure)     { FactoryGirl.create(:structure, :with_contact_email) }
  let(:token)         { stripe_helper.generate_card_token }
  let(:subscription)  { plan.create_subscription!(structure, token) }

  subject { FactoryGirl.create(:subscriptions_invoice, structure: structure, subscription: subscription) }

  it { should belong_to(:structure) }
  it { should belong_to(:subscription) }

  describe '#stripe_invoice' do
    context "when there's a stripe_invoice_id" do
      it 'returns nil' do
        expect(subject.stripe_invoice).to be_nil
      end
    end

    context "when there's a stripe_invoice_id" do

      before do
        subject.stripe_invoice_id = structure.stripe_customer.invoices.first.id
        subject.save
      end

      it 'returs a Stripe::Invoice' do
        stripe_invoice = Stripe::Invoice

        expect(subject.stripe_invoice).to be_a(stripe_invoice)
      end

    end

  end
end
