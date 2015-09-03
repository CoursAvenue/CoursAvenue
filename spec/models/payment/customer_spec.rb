require 'rails_helper'
require 'stripe_mock'

RSpec.describe Payment::Customer, type: :model, with_stripe: true do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }
  let(:stripe_helper) { StripeMock.create_test_helper }

  describe '#stripe_customer' do
    context 'when not a stripe customer' do
      it 'returns nil' do
        customer = FactoryGirl.build_stubbed(:payment_customer)
        expect(customer.stripe_customer).to be_nil
      end
    end

    context 'when a stripe customer' do
      it 'returns a Stripe::Customer object' do
        customer = FactoryGirl.build_stubbed(:payment_customer, :with_structure)
        stripe_customer = Stripe::Customer.create({
          card:  stripe_helper.generate_card_token,
          email: customer.email
        })
        customer.stripe_customer_id = stripe_customer.id

        expect(customer.stripe_customer).to be_a(Stripe::Customer)
      end
    end
  end

  describe '#create_stripe_customer' do
    context 'when the token is not provided' do
      it 'returns nil' do
        customer = FactoryGirl.build_stubbed(:payment_customer, :with_structure)
        expect(customer.create_stripe_customer(nil)).to be_nil
      end
    end

    context 'when the token is provided' do
      it 'returns a new Stripe::Customer' do
        customer = FactoryGirl.create(:payment_customer, :with_structure)
        token = stripe_helper.generate_card_token

        expect(customer.create_stripe_customer(token)).to be_a(Stripe::Customer)
      end

      it 'saves the client id as metadata' do
        customer = FactoryGirl.create(:payment_customer, :with_structure)
        token = stripe_helper.generate_card_token
        stripe_customer = customer.create_stripe_customer(token)

        expect(stripe_customer.metadata[customer.client_type]).to eq(customer.client_id)
      end

      it 'saves the stripe customer id' do
        customer = FactoryGirl.create(:payment_customer, :with_structure)
        token = stripe_helper.generate_card_token
        stripe_customer = customer.create_stripe_customer(token)

        expect(customer.stripe_customer_id).to eq(stripe_customer.id)
      end
    end
  end
end
