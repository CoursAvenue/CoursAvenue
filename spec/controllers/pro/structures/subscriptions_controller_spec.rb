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

    context 'when the structure is trialing' do
      let!(:subscription) { plan.create_subscription!(structure) }

      it 'assigns the subscription' do
        get :index, structure_id: structure.id

        expect(assigns(:subscription)).to eq(subscription)
      end

      it 'renders the subscription details partial' do
        get :index, structure_id: structure.id

        expect(response).to render_template(partial: '_subscription_details')
      end

      it 'renders the trial subscription partial' do
        get :index, structure_id: structure.id

        expect(response).to render_template(partial: '_subscription_in_trial')
      end
    end

    context 'when the structure is subscribed' do
      let!(:subscription) { plan.create_subscription!(structure) }

      before do
        subscription.charge!(token)
      end

      it 'assigns the subscription' do
        get :index, structure_id: structure.id

        expect(assigns(:subscription)).to eq(subscription)
      end

      it 'renders the subscription details partial' do
        get :index, structure_id: structure.id

        expect(response).to render_template(partial: '_subscription_details')
      end

      it 'renders the running subscription partial' do
        get :index, structure_id: structure.id

        expect(response).to render_template(partial: '_subscription_running')
      end
    end

    context "when the structure's subscription is canceled" do
      let!(:subscription) { plan.create_subscription!(structure) }

      before do
        subscription.charge!(token)
        subscription.cancel!(at_period_end: false)
      end

      it 'assigns the subscription' do
        get :index, structure_id: structure.id

        expect(assigns(:subscription)).to eq(subscription)
      end

      it 'renders the subscription details partial' do
        get :index, structure_id: structure.id

        expect(response).to render_template(partial: '_subscription_details')
      end

      it 'renders the canceled subscription partial' do
        get :index, structure_id: structure.id

        expect(response).to render_template(partial: '_subscription_canceled')
      end
    end
  end

  describe '#create' do
    subject { post :create, { structure_id: structure.id, plan_id: plan.id } }

    it 'redirects to the index page' do
      expect(subject).to redirect_to(action: :index, structure_id: structure.slug)
    end

    context 'with a coupon code' do
      let(:coupon) { FactoryGirl.create(:subscriptions_coupon) }

      subject do
        post :create, {
          structure_id: structure.id,
          plan_id:      plan.id,
          coupon_code:  coupon.code
        }
      end

      it 'creates a new subscription' do
        expect{ subject }.to change { Subscription.count }.by(1)
      end

      it 'creates a new subscription' do
        expect { subject }.to change { Subscription.count }.by(1)
        expect(structure.subscription.has_coupon?).to be_truthy
      end
    end
  end

  describe '#cancel' do
    render_views

    let(:subscription) { plan.create_subscription!(structure) }

    before do
      subscription.charge!(token)
    end

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

    let(:subscription) { plan.create_subscription!(structure) }

    before do
      subscription.charge!(token)
    end

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

  describe 'activate' do
  end

  describe '#reactivate' do
  end
end
