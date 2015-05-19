require 'rails_helper'
require 'stripe_mock'

describe ManagedAccountForm, with_stripe: true do
  context 'validations' do
    it { should validate_presence_of(:stripe_bank_token) }
    it { should validate_presence_of(:structure_id) }
  end

  describe '#save' do
    context 'when not valid' do
      subject { ManagedAccountForm.new }

      it "doesn't save the object" do
        expect(subject.save).to be_falsy
      end
    end

    context 'when valid' do
      before(:all) { StripeMock.start }
      after(:all)  { StripeMock.stop }

      let(:stripe_helper) { StripeMock.create_test_helper }
      let(:token)         { stripe_helper.generate_card_token }
      let(:structure)     { FactoryGirl.create(:structure, :with_contact_email) }

      subject { ManagedAccountForm.new(structure_id: structure.id, stripe_bank_token: token) }

      it 'saves the object' do
        expect(subject.save).to be_truthy
      end

      it 'creates a managed account for the structure' do
        subject.save
        structure.reload

        expect(structure.stripe_managed_account).to_not be_nil
      end

    end
  end
end
