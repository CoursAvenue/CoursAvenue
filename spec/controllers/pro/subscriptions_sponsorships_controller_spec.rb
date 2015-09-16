require 'rails_helper'
require 'stripe_mock'

describe Pro::SubscriptionsSponsorshipsController, with_stripe: true do
  include Devise::TestHelpers

  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:plan)          { FactoryGirl.create(:subscriptions_plan) }

  let(:structure)    { FactoryGirl.create(:structure_with_admin, :with_contact_email) }
  let(:admin)        { structure.admin }
  let(:token)        { stripe_helper.generate_card_token }
  let(:subscription) { plan.create_subscription!(structure) }

  let(:sponsor_structure)    { FactoryGirl.create(:structure_with_admin, :with_contact_email) }
  let(:sponsor_token)        { stripe_helper.generate_card_token }
  let(:sponsor_subscription) { plan.create_subscription!(sponsor_structure) }

  let(:sponsorship) { sponsor_subscription.sponsorships.create(sponsored_email: admin.email) }

  before do
    subscription.charge!(token)
  end

  describe '#show' do
    render_views

    context 'when the sponsorship exists' do
      let(:random_token) { SecureRandom.urlsafe_base64 }

      it 'redirect to the home page' do
        get :show, id: random_token

        expect(response).to redirect_to(pro_root_path)
      end
    end

    it 'assigns the sponsorship' do
      get :show, id: sponsorship.token

      expect(assigns(:sponsorship)).to eq(sponsorship)
    end

    it 'assigns the structure' do
      get :show, id: sponsorship.token

      expect(assigns(:structure)).to eq(sponsor_structure)
    end

    context 'when the structure is connected' do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:pro_admin]

        sign_in admin
      end

      it 'stores the subscription token in the session' do
        get :show, id: sponsorship.token

        expect(session[:sponsorship_token]).to eq(sponsorship.token)
      end

      it 'redirects to the subscription creation page' do
        get :show, id: sponsorship.token

        expect(response).to redirect_to(
          pro_structure_subscriptions_path(structure, sponsorship_token: sponsorship.token)
        )
      end
    end

    context 'when the structure is not connected' do
      it 'stores the subscription token in the session' do
        get :show, id: sponsorship.token

        expect(session[:sponsorship_token]).to eq(sponsorship.token)
      end

      it 'stores the page to be redirected to in the session' do
        get :show, id: sponsorship.token

        expect(session[:pro_admin_return_to]). to eq(
          pro_structure_subscriptions_path('__STRUCTURE_ID__', sponsorship_token: sponsorship.token)
        )
      end
    end
  end
end
