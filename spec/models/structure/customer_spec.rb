require 'rails_helper'

RSpec.describe Structure::Customer, type: :model, with_stripe: true do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }

  context 'associations' do
    it { should belong_to(:structure) }
    it { should have_one(:subscription) }
    it { should have_many(:invoices) }
  end

  describe '#stripe_customer' do
    context 'when not a stripe customer' do
      it 'returns nil' do
        customer = FactoryGirl.build_stubbed(:structure_customer)
        expect(customer.stripe_customer).to be_nil
      end
    end

    context 'when a stripe customer' do
      it 'returns a Stripe::Customer object' do
        customer = FactoryGirl.build_stubbed(:structure_customer)
        stripe_customer = Stripe::Customer.create({
          email: customer.structure_email,
          card: stripe_helper.generate_card_token
        })
        customer.stripe_customer_id = stripe_customer.id

        expect(customer.stripe_customer).to be_a(Stripe::Customer)
      end
    end
  end

  describe '#create_stripe_customer' do
    context 'when the token is not provided' do
      it 'returns nil' do
        customer = FactoryGirl.create(:structure_customer)
        expect(customer.create_stripe_customer(nil)).to eq(nil)
      end
    end

    context 'when the token is provided' do
      it 'returns a new Stripe::Customer' do
        token = stripe_helper.generate_card_token
        customer = FactoryGirl.create(:structure_customer)
        stripe_customer_type = Stripe::Customer
        stripe_customer = customer.create_stripe_customer(token)

        expect(stripe_customer).to be_a(stripe_customer_type)
      end

      it 'saves the structure id as metadata' do
        token = stripe_helper.generate_card_token
        customer = FactoryGirl.create(:structure_customer)
        stripe_customer = customer.create_stripe_customer(token)

        expect(stripe_customer.metadata[:structure_id]).to eq(customer.structure_id)
      end

      it 'saves the stripe customer id' do
        token = stripe_helper.generate_card_token
        customer = FactoryGirl.create(:structure_customer)
        stripe_customer = customer.create_stripe_customer(token)

        expect(customer.stripe_customer_id).to eq(stripe_customer.id)
      end
    end
  end

  describe '#active' do
    context 'when there is not a stripe customer' do
      it 'returns false' do
        customer = FactoryGirl.build_stubbed(:structure_customer)
        expect(customer.active?).to be_falsy
      end
    end

    context 'when there is not a subscription' do
      it 'returns false' do
        customer = FactoryGirl.build_stubbed(:structure_customer)
        stripe_customer = Stripe::Customer.create({
          email: customer.structure_email,
          card: stripe_helper.generate_card_token
        })
        customer.stripe_customer_id = stripe_customer.id
        expect(customer.active?).to be_falsy
      end
    end
  end
end
