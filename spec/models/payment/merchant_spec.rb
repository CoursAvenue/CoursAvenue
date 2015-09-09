require 'rails_helper'

RSpec.describe Payment::Merchant, type: :model, with_stripe: true do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }

  describe '#stripe_managed_account' do
    context 'when not a managed account' do
      it 'returns nil' do
        merchant = FactoryGirl.build_stubbed(:payment_merchant)
        expect(merchant.stripe_managed_account).to be_nil
      end
    end

    context 'when a managed account' do
      it 'returns the Stripe::Account object' do
        merchant = FactoryGirl.build_stubbed(:payment_merchant)
        managed_account = Stripe::Account.create({
          managed: true,
          country: 'FR'
        })
        merchant.stripe_managed_account_id = managed_account.id

        expect(merchant.stripe_managed_account).to be_a(Stripe::Account)
      end
    end
  end

  describe '#create_managed_account' do

    let(:bank_account) do
      StripeMock.generate_bank_token({
        bank_account: { country: 'FR', account_number: '000123456789', currency: 'EUR' }
      })
    end

    context 'when not a managed account' do
      context 'without the bank account' do
        xit 'return false' do
          return_value = subject.create_managed_account

          expect(return_value).to be_falsy
          expect(subject.stripe_managed_account_id).to be_nil
          expect(subject.stripe_managed_account).to be_nil
        end
      end

      context 'with a bank account' do
        xit 'creates a managed account' do
          subject.create_managed_account({ bank_account: bank_account })

          expect(subject.stripe_managed_account_id).to_not be_nil
          expect(subject.stripe_managed_account).to be_a(Stripe::Account)
        end

        xit 'saves the API keys for this account' do
          subject.create_managed_account({ bank_account: bank_account })

          expect(subject.stripe_managed_account_secret_key).to_not      be_nil
          expect(subject.stripe_managed_account_publishable_key).to_not be_nil
        end
      end
    end

    context 'when a managed account' do
      xit "doesn't do anything" do
        subject.create_managed_account({ bank_account: bank_account })

        expect(Stripe::Account).to_not receive(:create)
      end
    end
  end

  describe '#update_managed_account' do
    context "when there's no managed account" do
      xit 'returns nil' do
        expect(subject.update_managed_account({})).to be_nil
      end
    end

    context "when there's a managed account" do
      let(:bank_token) { { country: 'FR', currency: 'EUR', account_number: '000123456789' } }

      before do
        subject.create_managed_account({ email: Faker::Internet.email, bank_account: bank_token })
        subject.reload
      end

      context "when there are no options" do
        xit 'returns nil' do
          expect(subject.update_managed_account({})).to be_nil
        end
      end

      context 'when there are options' do

        context 'when there are invalid options' do
          xit "only updates the valid options" do
            options = { email: Faker::Internet.email, lorem: 'ipsum' }
            managed_account = subject.update_managed_account(options.dup)

            expect(managed_account[:email]).to eq(options[:email])
            expect(managed_account[:lorem]).to be_nil
          end
        end

        xit 'returns the managed account' do
          subject.reload
          options = { email: Faker::Internet.email }
          managed_account = subject.update_managed_account(options.dup)

          expect(managed_account).to be_a(Stripe::Account)
        end

        xit 'updates the managed account' do
          options = { email: Faker::Internet.email }
          managed_account = subject.update_managed_account(options.dup)

          expect(managed_account.email).to eq(options[:email])
        end
      end
    end
  end

  describe '#can_receive_payments?' do
    subject { FactoryGirl.create(:structure, :with_contact_email) }

    context 'when not a managed account' do
      xit 'returns false' do
        expect(subject.can_receive_payments?).to be_falsy
      end
    end

    context 'when a managed account' do
      context 'some information is missing' do
        before do
          subject.create_managed_account
        end

        xit 'returns false' do
          expect(subject.can_receive_payments?).to be_falsy
        end
      end

      context 'when all needed information have been submitted' do
        let(:bank_token)     { { country: 'FR', currency: 'EUR', account_number: '000123456789' } }
        let(:tos_acceptance) { { date: Time.now.to_i, ip: Faker::Internet.ip_v4_address } }
        let(:legal_entity) do
          {
            type: 'individual',
            address: {
              line1:       Faker::Address.street_address,
              line2:       Faker::Address.secondary_address,
              city:        Faker::Address.city,
              state:       Faker::Address.state,
              postal_code: Faker::Address.postcode,
              country:     'FR'
            },
            dob: {
              day:   (1..28).to_a.sample.to_s,
              month: (1..12).to_a.sample.to_s,
              year:  (1950..1996).to_a.sample.to_s
            },
            first_name: Faker::Name.first_name,
            last_name:  Faker::Name.last_name,
            personal_id_number: Faker::Number.number(15)
          }
        end

        before do
          subject.create_managed_account({
            legal_entity:   legal_entity,
            bank_account:   bank_token,
            tos_acceptance: tos_acceptance
          })
        end

        xit 'returns true' do
          expect(subject.can_receive_payments?).to be_truthy
        end
      end
    end
  end
end
