require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Invoice, type: :model do
  after(:context) do
    # Stripe::Customer.all(limit: 100).each(&:delete)
    # Stripe::Plan.all(limit: 100).each(&:delete)
    # Stripe::Invoice.all(limit: 100).each(&:delete)
  end

  subject { FactoryGirl.create(:subscriptions_invoice) }

  it { should belong_to(:structure) }
  it { should belong_to(:subscription) }

  describe '#stripe_invoice' do
    context "when there's a stripe_invoice_id" do
      it 'returns nil' do
        expect(subject.stripe_invoice).to be_nil
      end
    end

    context "when there's a stripe_invoice_id" do
      subject { create_invoice(subscription) }

      it 'returs a Stripe::Invoice' do
        stripe_invoice = Stripe::Invoice

        expect(subject.stripe_invoice).to be_a(stripe_invoice)
      end

    end

  end
end
