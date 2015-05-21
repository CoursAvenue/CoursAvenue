require 'rails_helper'
require 'stripe_mock'

RSpec.describe Subscriptions::Invoice, type: :model, with_stripe: true do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  context 'associations' do
    it { should belong_to(:structure) }
    it { should belong_to(:subscription) }
  end

  let(:stripe_helper)  { StripeMock.create_test_helper }
  let(:plan)           { FactoryGirl.create(:subscriptions_plan) }
  let(:structure)      { FactoryGirl.create(:structure, :with_contact_email) }
  let(:token)          { stripe_helper.generate_card_token }
  let!(:subscription)  { plan.create_subscription!(structure) }
  let(:stripe_invoice) { Stripe::Invoice.upcoming(customer: structure.stripe_customer_id) }

  subject do
    FactoryGirl.create(:subscriptions_invoice, structure: structure, subscription: subscription,
                       stripe_invoice_id: stripe_invoice.id)
  end

  before do
    subscription.charge!(token)
  end

  describe '.create_from_stripe_invoice' do
    it "returns nothing if there's no invoice" do
      invoice = Subscriptions::Invoice.create_from_stripe_invoice(nil)

      expect(invoice).to be_nil
    end

    it "returns the already created invoice if it already exists" do
      subject
      invoice = Subscriptions::Invoice.create_from_stripe_invoice(stripe_invoice)

      expect(invoice).to eq(subject)
    end

    it 'creates a new invoice' do
      subscription # So the stripe_customer_id creates itself.
      invoice = Subscriptions::Invoice.create_from_stripe_invoice(stripe_invoice)

      expect(invoice).to be_a(Subscriptions::Invoice)
    end

    it 'sets the payed_at date' do
      subscription # So the stripe_customer_id creates itself.
      invoice = Subscriptions::Invoice.create_from_stripe_invoice(stripe_invoice)

      expect(invoice.payed_at).to_not be_nil
    end
  end

  describe '#stripe_invoice' do
    context "when there isn't a stripe_invoice_id" do
      subject { FactoryGirl.create(:subscriptions_invoice, structure: structure, subscription: subscription) }

      it 'returns nil' do
        expect(subject.stripe_invoice).to be_nil
      end
    end

    context "when there's a stripe_invoice_id" do
      it 'returs a Stripe::Invoice' do
        stripe_invoice = Stripe::Invoice

        expect(subject.stripe_invoice).to be_a(stripe_invoice)
      end
    end
  end

  describe 'pdf_url' do
    context "when there isn't a stripe_invoice_id" do
      subject { FactoryGirl.create(:subscriptions_invoice, structure: structure, subscription: subscription) }

      it "returns nil" do
        expect(subject.pdf_url).to be_nil
      end
    end

    context "when there's a stripe_invoice_id" do
      let(:bucket_pattern) { /.*\/coursavenue-staging.*/ }

      it "returns the generated PDF's URL" do
        allow(PDFGenerator).to receive(:generate_invoice).and_return(nil)

        expect(subject.pdf_url).to match(bucket_pattern)
      end
    end
  end

  describe '#file_path' do
    it 'returns the file_path of the invoice on S3' do
      invoice_file_path = "invoices/#{subject.structure.slug}/subscriptions/#{subject.id}.pdf"

      expect(subject.file_path).to eq(invoice_file_path)
    end
  end

  describe '#amount' do
    context "when there's a stripe invoice" do
      subject { FactoryGirl.create(:subscriptions_invoice,
                                   structure: structure, subscription: subscription) }

      it 'returns the plan amount' do
        expect(subject.amount).to eq(plan.amount)
      end
    end

    context "when there's a stripe invoice" do
      it 'returns the amount on the stripe invoice' do
        stripe_invoice_amount = subject.stripe_invoice.amount_due / 100.0

        expect(subject.amount).to eq(stripe_invoice_amount)
      end
    end
  end

  describe '#coupon_amount' do
    context "when there isn't a coupon" do
      it { expect(subject.coupon_amount).to eq(0) }
    end

    context "when there's a coupon" do
      let(:coupon_amount) { (1..10).to_a.sample.to_f }
      let(:coupon)        { FactoryGirl.create(:subscriptions_coupon, amount: coupon_amount) }

      before do
        subscription.apply_coupon(coupon)
      end

      it 'returns the amount of the coupon code' do
        expect(subject.coupon_amount).to eq(coupon_amount)
      end
    end
  end
end
