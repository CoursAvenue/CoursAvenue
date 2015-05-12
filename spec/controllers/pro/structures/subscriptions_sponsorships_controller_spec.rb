require 'rails_helper'
require 'stripe_mock'

describe Pro::Structures::SubscriptionsSponsorshipsController do
  include Devise::TestHelpers

  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let!(:structure)    { FactoryGirl.create(:structure_with_admin, :with_contact_email) }
  let!(:admin)        { structure.main_contact }
  let(:plan)          { FactoryGirl.create(:subscriptions_plan) }
  let(:token)         { stripe_helper.generate_card_token }
  let!(:subscription) { plan.create_subscription!(structure) }

  before do
    sign_in admin
  end

  context 'before actions' do
    it { should use_before_action(:authenticate_pro_admin!) }
    it { should use_before_action(:set_subscription) }
  end

  describe '#index' do
    render_views

    let(:sponsorships) { [] }

    context 'when there is no subscription' do
      before do
        structure.subscription = nil
        structure.save
      end

      it 'redirect to the subscription registration page' do
        get :index, structure_id: structure.slug

        expect(response).to redirect_to(pro_structure_subscriptions_path(structure))
      end
    end

    it 'renders the index template' do
      get :index, structure_id: structure.slug

      expect(response).to render_template('index')
    end

    it 'assigns the sponsorships' do
      get :index, structure_id: structure.slug

      expect(assigns(:sponsorships).to_a).to match_array(sponsorships)
    end

    context 'when the subscription is not active' do
      before do
        subscription.trial_end              = 1.day.ago
        subscription.canceled_at            = 1.day.ago
        subscription.stripe_subscription_id = Faker::Number.digit
        subscription.save

        structure.reload
        subscription.reload
      end

      it 'redirects to the subscription creation' do
        get :index, structure_id: structure.slug

        expect(response).to redirect_to(pro_structure_subscriptions_path(structure))
      end
    end

    context 'when the subscription is active' do
      before do
        subscription.charge!(token)
      end

      context 'when there are sponsorships' do
        let!(:sponsorships) { 3.times.map { subscription.sponsorships.create(sponsored_email: Faker::Internet.email) } }
        it 'shows the list of sponsorships' do
          get :index, structure_id: structure.slug

          expect(response).to render_template(partial: '_sponsorships_list')
        end

        it 'assigns the sponsorships' do
          get :index, structure_id: structure.slug

          expect(assigns(:sponsorships).map(&:id).to_a.compact)
            .to match_array(sponsorships.map(&:id))
        end
      end
    end
  end

  describe 'create' do
    let(:emails_count) { 5 }
    let(:emails)        { emails_count.times.map { Faker::Internet.email }.join(' ') }
    let(:message)       { Faker::Lorem.paragraph }

    it 'creates sponsorships' do
      expect { post :create, structure_id: structure.slug, emails: emails, message: message }.
        to change { Subscriptions::Sponsorship.count }.by(emails_count)
    end

    it 'sends a notification to the sponsee', with_mail: true do
      expect { post :create, structure_id: structure.slug, emails: emails, message: message }.
        to change { ActionMailer::Base.deliveries.count }.by(emails_count)
    end

    it 'redirects to the homepage' do
      post :create, structure_id: structure.slug, emails: emails, message: message

      expect(response).to redirect_to(action: :index, structure_id: structure.slug)
    end
  end
end
