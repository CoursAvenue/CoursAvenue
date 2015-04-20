require 'rails_helper'
require 'stripe_mock'

RSpec.describe Pro::Structures::SubscriptionsController, type: :controller do
  include Devise::TestHelpers

  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it { should use_before_action(:authenticate_pro_admin!) }
  it { should use_before_action(:set_structure) }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let!(:structure)    { FactoryGirl.create(:structure_with_admin, :with_contact_email) }
  let!(:admin)        { structure.main_contact }
  let(:plan)          { FactoryGirl.create(:subscriptions_plan) }
  let(:token)         { stripe_helper.generate_card_token }

  before do
    sign_in admin
  end

  describe '#index' do
    render_views

    it 'renders the index template' do
      get :index, structure_id: structure.id

      should render_template('index')
    end

    context "when the structure isn't subscribed" do
      it 'renders the unsubscribed structure partial' do
        get :index, structure_id: structure.id

        expect(response).to render_template(partial: '_subscription_plans')
      end
    end

    context 'when the structure is subscribed' do
      let!(:subscription) { plan.create_subscription!(structure, token) }

      it 'assigns the subscription' do
        get :index, structure_id: structure.id

        expect(assigns(:subscription)).to eq(subscription)
      end

      it 'renders the subscribed structure partial' do
        get :index, structure_id: structure.id

        expect(response).to render_template(partial: '_subscription_details')
      end
    end
  end

  describe '#create' do
    context "when it is a new subscriber" do
      context 'with a stripe token' do
        subject { post :create, { structure_id: structure.id, plan_id: plan.id, stripe_token: token } }

        it 'creates a new subscription' do
          expect{ subject }.to change { Subscription.count }.by(1)
        end

        it 'redirects to the index page' do
          expect(subject).to redirect_to(action: :index, structure_id: structure.slug)
        end
      end

      context 'without a stripe token' do
        subject { post :create, { structure_id: structure.id, plan_id: plan.id } }

        it "doesn't create a new subscription" do
          expect { subject }.to_not change { Subscription.count }
        end

        it 'sends an error code' do
          expect(subject).to have_http_status(400)
        end
      end
    end

    context "when it's an existing subscribed" do
      subject { post :create, { structure_id: structure.id, plan_id: plan.id } }
      before do
        structure.create_stripe_customer(token)
      end

      it 'creates a new subscription' do
        expect { subject }.to change { Subscription.count }.by(1)
      end

    end
  end

  describe '#cancel' do
    render_views

    let(:subscription) { plan.create_subscription!(structure, token) }

    it 'renders the cancel template' do
      get :cancel, structure_id: structure.slug, id: subscription.id

      expect(response).to render_template('cancel')
      expect(response).to render_with_layout('admin')
    end

    it 'renders without a layout if it is a xhr request' do
      xhr :get, :cancel, structure_id: structure.slug, id: subscription.id

      expect(response).to_not render_with_layout('admin')
    end

      it 'assigns the subscription' do
        get :cancel, structure_id: structure.slug, id: subscription.id

        expect(assigns(:subscription)).to eq(subscription)
      end
  end

  describe '#confirm_cancellation' do
    render_views

    let(:subscription) { plan.create_subscription!(structure, token) }

    it 'renders the cancel template' do
      get :confirm_cancellation, structure_id: structure.slug, id: subscription.id

      expect(response).to render_template('confirm_cancellation')
      expect(response).to render_with_layout('admin')
    end

    it 'renders without a layout if it is a xhr request' do
      xhr :get, :confirm_cancellation, structure_id: structure.slug, id: subscription.id

      expect(response).to_not render_with_layout('admin')
    end

      it 'assigns the subscription' do
        get :confirm_cancellation, structure_id: structure.slug, id: subscription.id

        expect(assigns(:subscription)).to eq(subscription)
      end
  end

  describe '#destroy' do
  end

  describe '#reactivate' do
  end
end
