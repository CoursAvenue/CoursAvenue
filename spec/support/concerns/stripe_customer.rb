require 'rails_helper'
require 'stripe_mock'

shared_examples_for 'StripeCustomer' do
  subject do
    case described_class.to_s
    when 'User'
      FactoryGirl.create(:user)
    when 'Structure'
      FactoryGirl.create(:structure, :with_contact_email)
    end
  end

  describe 'Stripe' do
    before(:all) { StripeMock.start }
    after(:all)  { StripeMock.stop }

    let(:stripe_helper) { StripeMock.create_test_helper }

    describe '#stripe_customer' do
      context 'when not a stripe customer' do
        it 'returns nil' do
          expect(subject.stripe_customer).to be_nil
        end
      end

      context 'when a stripe customer' do
        subject { FactoryGirl.create(:user) }

        before do
          customer = Stripe::Customer.create({
            email: subject.email,
            card:  stripe_helper.generate_card_token
          })
          subject.stripe_customer_id = customer.id

          subject.save
        end

        it 'returns a Stripe::Customer object' do
          stripe_customer = Stripe::Customer

          expect(subject.stripe_customer).to be_a(stripe_customer)
        end
      end
    end

    describe '#create_stripe_customer' do
      context 'when the token is not provided' do
        it 'returns nil' do
          expect(subject.create_stripe_customer(nil)).to eq(nil)
        end
      end

      context 'when the token is provided' do
        let(:token)         { stripe_helper.generate_card_token }
        let(:stripe_helper) { StripeMock.create_test_helper }

        it 'returns a new Stripe::Customer' do
          stripe_customer_type = Stripe::Customer
          stripe_customer      = subject.create_stripe_customer(token)

          expect(stripe_customer).to be_a(stripe_customer_type)
        end

        it 'saves the object id as metadata' do
          stripe_customer = subject.create_stripe_customer(token)
          key = described_class.to_s.downcase.to_sym

          expect(stripe_customer.metadata[key]).to eq(subject.id)
        end

        it 'saves the stripe customer id' do
          stripe_customer = subject.create_stripe_customer(token)

          expect(subject.stripe_customer_id).to eq(stripe_customer.id)
        end
      end
    end
  end

end
