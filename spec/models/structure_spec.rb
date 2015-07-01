# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'stripe_mock'

describe Structure do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it { should have_many(:newsletters) }
  it { should have_many(:gift_certificates) }
  it { should have_one(:crm_lock) }

  subject {structure}
  let(:structure) { FactoryGirl.create(:structure) }

  it { should be_valid }
  it { expect(structure.active).to be true}

  context 'contact' do
    it 'returns admin contact' do
      admin = FactoryGirl.create(:admin)
      admin.structure_id = structure.id
      structure.admins << admin

      expect(structure.contact_email).to eq(admin.email)
      expect(structure.contact_name).to eq(admin.name)
      expect(structure.main_contact).to eq(admin)
    end
  end

  context 'activate' do
    it 'activates' do
      structure.active = false
      structure.activate!
      expect(structure.active).to be true
    end
  end

  context 'disable' do
    it 'disables' do
      FactoryGirl.create(:course, structure: structure)
      courses = structure.courses
      structure.active = true
      structure.disable!
      expect(structure.active).to be false
      courses.each{ |c| expect(c.active).to be false }
    end
  end

  context 'destroy' do
    it 'destroys everything' do
      places = structure.places
      structure.destroy
      expect(structure.deleted?).to be true
      places.each{ |p| expect(p.deleted?).to be true }
    end
  end

  context 'address' do
    it 'includes street' do
      expect(structure.address).to include(structure.street)
    end
    it 'includes city' do
      expect(structure.address).to include(structure.city.name)
    end
  end

  context 'comments' do
    it 'retrieves course comments' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment_review)
      expect(structure.comments).to include(comment)
    end
  end

  it 'updates comments_count' do
    @structure = FactoryGirl.create(:structure)
    FactoryGirl.create(:accepted_comment, commentable_id: @structure.id, commentable_type: 'Structure')
    expect(@structure.reload.comments_count).to eq(1)
    FactoryGirl.create(:accepted_comment, commentable_id: @structure.id, commentable_type: 'Structure')
    expect(@structure.reload.comments_count).to eq(2)
    FactoryGirl.create(:accepted_comment, commentable_id: @structure.id, commentable_type: 'Structure')
    expect(@structure.reload.comments_count).to eq 3
  end

  context 'tagging' do

    describe 'add_tags_on' do
      let(:structure) { FactoryGirl.create(:structure_with_user_profiles_with_tags) }
      let(:user_profile) { structure.user_profiles.first }
      let(:tags) { ['Master of the Arts', 'powerful', 'brazen', 'churlish'] }

      it "adds the given tags to the given profile" do
        pending("This test still behaves poorly, even though the same test works both online and in the console.")
        length = user_profile.tags.length

        user_profile.reload
        structure.add_tags_on(user_profile, tags)
        user_profile.reload

        expect(user_profile.tags.length).to eq(length + tags.length)
      end

      # it "does not overwrite the existing tags"
      # it "does not create duplicate tags"

    end

    describe 'create_tag' do
      let(:structure) { FactoryGirl.create(:structure) }
      it "creates a new tag" do
        length = structure.owned_tags.length
        structure.create_tag(Faker::Name.name)
        expect(structure.owned_tags.length).to eq (length + 1)
      end
    end
  end

  context 'funding_types' do
    context 'getters' do
      describe '#funding_types' do
        it 'returns FundingTypes' do
          structure.funding_types = [FundingType.first]
          expect(structure.funding_types).to eq [FundingType.first]
        end
      end
      describe '#funding_type_ids' do
        it 'returns an array of ids' do
          structure.funding_types = [FundingType.first]
          expect(structure.funding_type_ids).to eq [FundingType.first.id]
        end
      end
    end
    context 'setters' do
      describe '#funding_type_ids=' do
        it 'stores ids if given an array of ids' do
          structure.funding_type_ids = [1, 2]
          expect(structure.read_attribute(:funding_type_ids)).to eq '1,2'
        end

        it 'stores ids if given a string' do
          structure.funding_type_ids = '1,2'
          expect(structure.read_attribute(:funding_type_ids)).to eq '1,2'
        end
      end

      describe '#funding_type=' do
        it 'stores ids if given an array of FundingType' do
          structure.funding_types = [FundingType.first, FundingType.last]
          expect(structure.read_attribute(:funding_type_ids)).to eq "#{FundingType.first.id},#{FundingType.last.id}"
        end

        it 'stores ids if given an array of ids' do
          structure.funding_types = FundingType.first
          expect(structure.read_attribute(:funding_type_ids)).to eq FundingType.first.id.to_s
        end
      end
    end
  end

  describe '#highlighted_comment' do
    it 'returns highlighted_comment' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment_review)
      allow(subject).to receive_messages(:highlighted_comment_id => comment.id)
      expect(subject.highlighted_comment_id).to be comment.id
    end
  end

  describe '#highlight_comment!' do
    it 'sets highlighted_comment_id' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment_review)
      subject.highlight_comment! comment
      expect(subject.highlighted_comment_id).to be comment.id
    end
  end

  describe '#strip_name' do
    it 'removes end spaces' do
      subject.name = ' test name '
      subject.save
      expect(subject.name).to eq 'test name'
    end
  end

  context 'validations' do
    describe '#no_contacts_in_name' do
      it 'has errors on name' do
        subject.name = "www.test.com"
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages).to include :name
      end
    end

    describe '#subject_parent_and_children' do
      it "doesn't have any subjects" do
        subject.subjects = []
        subject.valid?
        expect(subject.errors.messages).to include :subjects
        expect(subject.errors.messages).to include :children_subjects
      end

      it "doesn't have child subjects" do
        subject.subjects = [Subject.roots.first]
        subject.valid?
        expect(subject.errors.messages).not_to include :subjects
        expect(subject.errors.messages).to include :children_subjects
      end
    end

    describe '#reject_places' do
      it 'rejects it' do
        expect(subject.send(:reject_places, { zip_code: '' })).to be(true)
      end

      it 'does not rejects it' do
        expect(subject.send(:reject_places, { zip_code: '75014' })).to be(false)
      end
    end

    describe '#reject_phone_number' do
      it 'rejects it' do
        expect(subject.send(:reject_phone_number, { number: '' })).to be(true)
      end

      it 'does not rejects it' do
        expect(subject.send(:reject_phone_number, { number: '04102401240' })).to be(false)
      end

      it 'destroys it' do
        attributes = { id: 4,  number: '' }
        subject.send :reject_phone_number, attributes
        expect(attributes[:_destroy]).to eq 1
      end
    end
  end

  context 'sleeping' do
    describe '#duplicate_structure' do

      let(:structure)            { FactoryGirl.create(:sleeping_structure) }

      # We start the spec by reloading the spec so it is created at that moment
      # and not when we access it for the first time in the assertion.
      it 'creates a new structure' do
        structure.reload

        expect { structure.duplicate_structure }.to change { Structure.count }.by(1)
      end

      it "doesn't create two new structures" do
        structure.duplicate_structure

        expect { structure.duplicate_structure }.to_not change { Structure.count }
      end

      it 'associates the new structure with the current structure' do
        sleeping_structure = structure.duplicate_structure

        expect(sleeping_structure).to_not be_nil
        expect(sleeping_structure.controled_structure).to eq structure
      end

      it 'makes the current structure inactive' do
        structure.duplicate_structure

        expect(structure.active).to be false
      end

      it 'makes the new structure active' do
        structure.duplicate_structure

        expect(structure.sleeping_structure.active).to be true
      end
    end

    describe '#wake_up!' do
      let(:structure)            { FactoryGirl.create(:sleeping_structure) }
      let(:admin)                { FactoryGirl.create(:admin) }
      let(:sleeping_structure)   { structure.duplicate_structure }

      before(:each) do
        admin.structure = structure
        structure.admins << admin

        admin.save
        structure.save

        sleeping_structure.reload
      end

      it 'wakes itself' do
        structure.wake_up!

        expect(structure.is_sleeping).to be false
      end

      it 'activates itself' do
        structure.wake_up!

        expect(structure.active).to be true
      end

      it 'destroys the sleeping structure' do
        structure.wake_up!

        structure.reload
        expect(structure.sleeping_structure).to be nil
      end
    end
  end

  describe '#contact_email' do
    context 'with an admin' do
      subject { FactoryGirl.create(:structure_with_admin) }

      it 'returns the admin email' do
        expect(subject.contact_email).to eq(subject.main_contact.email)
      end
    end

    context 'with a contact email' do
      subject { FactoryGirl.create(:structure, :with_contact_email) }

      it 'returns the contact email' do
        expect(subject.contact_email).to eq(subject.read_attribute(:contact_email))
      end
    end

    context 'without an admin or a contact email' do
      it 'returns nil' do
        expect(subject.contact_email).to be_nil
      end
    end
  end

  describe '#contact_mobile_phone' do
    context 'with an admin' do
      subject { FactoryGirl.create(:structure_with_admin) }

      it 'returns the admin mobile phone' do
        expect(subject.contact_mobile_phone).to eq(subject.main_contact.mobile_phone_number)
      end
    end

    context 'with a contact mobile phone' do
      subject { FactoryGirl.create(:structure, :with_contact_mobile_phone) }

      it 'returns the contact mobile phone' do
        expect(subject.contact_mobile_phone).to eq(subject.read_attribute(:contact_mobile_phone))
      end
    end

    context 'without an admin or a contact mobile phone' do
      it 'returns nil' do
        expect(subject.contact_mobile_phone).to be_nil
      end
    end
  end

  describe '#contact_phone' do
    context 'with an admin' do
      subject { FactoryGirl.create(:structure_with_admin) }

      it 'returns the admin phone' do
        expect(subject.contact_phone).to eq(subject.main_contact.phone_number)
      end
    end

    context 'with a contact phone' do
      subject { FactoryGirl.create(:structure, :with_contact_phone) }

      it 'returns the contact phone' do
        expect(subject.contact_phone).to eq(subject.read_attribute(:contact_phone))
      end
    end

    context 'without an admin or a contact phone' do
      it 'returns nil' do
        expect(subject.contact_phone).to be_nil
      end
    end
  end

  describe '#has_admin?' do
    context "when there's an admin" do
      subject { FactoryGirl.create(:structure_with_admin) }

      it 'returns true' do
        expect(subject.has_admin?).to be_truthy
      end
    end

    context "when there is no admin" do
      subject { FactoryGirl.create(:structure) }

      it 'returns true' do
        expect(subject.has_admin?).to be_falsy
      end
    end
  end

  describe '#parent_subjects' do
    let(:parent_subjects) { subject.subjects.uniq.map(&:parent).uniq }

    it { expect(subject.parent_subjects).to match_array(parent_subjects) }
  end

  describe '#independant?' do
    subject { FactoryGirl.create(:independant_structure) }

    it 'returns true' do
      expect(subject.independant?).to be_truthy
    end
  end

  context 'Stripe', with_stripe: true do
    let(:stripe_helper) { StripeMock.create_test_helper }

    it_behaves_like 'StripeCustomer'

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

        it 'saves the stripe customer id' do
          stripe_customer = subject.create_stripe_customer(token)

          expect(subject.stripe_customer_id).to eq(stripe_customer.id)
        end
      end
    end

    describe '#premium?' do
      context 'when not premium' do
        it { expect(subject.premium?).to be_falsy }
      end

      context 'when premium' do
        subject             { FactoryGirl.create(:structure, :with_contact_email) }
        let(:plan)          { FactoryGirl.create(:subscriptions_plan) }
        let(:stripe_helper) { StripeMock.create_test_helper }
        let(:token)     { stripe_helper.generate_card_token }

        before do
          subscription = plan.create_subscription!(subject)
          subscription.charge!(token)
        end

        it { expect(subject.premium?).to be_truthy }
      end
    end

    describe '#stripe_managed_account' do
      context 'when not a managed account' do
        it 'returns nil' do
          expect(subject.stripe_managed_account).to be_nil
        end
      end

      context 'when a managed account' do
        subject { FactoryGirl.create(:structure, :with_contact_email) }

        before do
          managed_account = Stripe::Account.create({
            managed: true,
            country: 'FR'
          })

          subject.stripe_managed_account_id = managed_account.id
          subject.save
        end

        it 'returns the Stripe::Account object' do
          managed_account = Stripe::Account

          expect(subject.stripe_managed_account).to be_a(Stripe::Account)
        end
      end
    end

    describe '#create_managed_account' do
      before(:all) { StripeMock.start }
      after(:all)  { StripeMock.stop }

      let(:bank_account) do
        StripeMock.generate_bank_token({
          bank_account: { country: 'FR', account_number: '000123456789', currency: 'EUR' }
        })
      end

      context 'when not a managed account' do
        context 'without the bank account' do
          it 'return false' do
            return_value = subject.create_managed_account

            expect(return_value).to be_falsy
            expect(subject.stripe_managed_account_id).to be_nil
            expect(subject.stripe_managed_account).to be_nil
          end
        end

        context 'with a bank account' do
          it 'creates a managed account' do
            subject.create_managed_account({ bank_account: bank_account })

            expect(subject.stripe_managed_account_id).to_not be_nil
            expect(subject.stripe_managed_account).to be_a(Stripe::Account)
          end

          it 'saves the API keys for this account' do
            subject.create_managed_account({ bank_account: bank_account })

            expect(subject.stripe_managed_account_secret_key).to_not      be_nil
            expect(subject.stripe_managed_account_publishable_key).to_not be_nil
          end
        end
      end

      context 'when a managed account' do
        it "doesn't do anything" do
          subject.create_managed_account({ bank_account: bank_account })

          expect(Stripe::Account).to_not receive(:create)
        end
      end
    end

    describe '#update_managed_account' do
      context "when there's no managed account" do
        it 'returns nil' do
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
          it 'returns nil' do
            expect(subject.update_managed_account({})).to be_nil
          end
        end

        context 'when there are options' do

          context 'when there are invalid options' do
            it "only updates the valid options" do
              options = { email: Faker::Internet.email, lorem: 'ipsum' }
              managed_account = subject.update_managed_account(options.dup)

              expect(managed_account[:email]).to eq(options[:email])
              expect(managed_account[:lorem]).to be_nil
            end
          end

          it 'returns the managed account' do
            subject.reload
            options = { email: Faker::Internet.email }
            managed_account = subject.update_managed_account(options.dup)

            expect(managed_account).to be_a(Stripe::Account)
          end

          it 'updates the managed account' do
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
        it 'returns false' do
          expect(subject.can_receive_payments?).to be_falsy
        end
      end

      context 'when a managed account' do
        context 'some information is missing' do
          before do
            subject.create_managed_account
          end

          it 'returns false' do
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

          it 'returns true' do
            expect(subject.can_receive_payments?).to be_truthy
          end
        end
      end
    end
  end

  describe '#lock_crm!' do
    before { structure.create_crm_lock }

    context 'when the crm is locked' do
      before { structure.lock_crm! }

      it 'does nothing' do
        expect { subject.lock_crm! }.
          to_not change { subject.crm_lock.locked? }
      end
    end

    context 'when the crm is unlocked' do
      it 'locks the crm' do
        expect { subject.lock_crm! }.
          to change { subject.crm_lock.locked? }.from(false).to(true)
      end
    end
  end

  describe '#unlock_crm!' do
    context 'when the crm is unlocked' do
      it 'does nothing' do
        expect { subject.unlock_crm! }.
          to_not change { subject.crm_lock.locked? }
      end
    end

    context 'when the crm is locked' do
      before { structure.lock_crm! }

      it 'unlocks the crm' do
        expect { subject.unlock_crm! }.
          to change { subject.crm_lock.locked? }.from(true).to(false)
      end
    end
  end
end
