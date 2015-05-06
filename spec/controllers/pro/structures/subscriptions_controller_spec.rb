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

        structure.reload

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

  describe '#stripe_payment_form' do
    render_views

    let(:subscription) { plan.create_subscription!(structure) }

    before do
      subscription.charge!(token)
    end

    it 'renders the cancel template' do
      get :stripe_payment_form, structure_id: structure.slug, id: subscription.id

      expect(response).to render_template('stripe_payment_form')
      expect(response).to render_with_layout('admin')
    end

    it 'renders without a layout if it is a xhr request' do
      xhr :get, :stripe_payment_form, structure_id: structure.slug, id: subscription.id

      expect(response).to_not render_with_layout('admin')
    end

      it 'assigns the subscription' do
        get :stripe_payment_form, structure_id: structure.slug, id: subscription.id

        expect(assigns(:subscription)).to eq(subscription)
      end
  end

  describe '#destroy' do
    render_views

    let(:subscription)       { plan.create_subscription!(structure) }
    let(:cancelation_reason) { Faker::Lorem.paragraph }

    before do
      subscription.charge!(token)
    end

    it 'cancels the subscription' do
      delete :destroy, structure_id: structure.slug, id: subscription.id
      subscription.reload

      expect(subscription.canceled?).to be_truthy
    end

    # it 'saves the cancelation reasons' do
    #   delete :destroy, structure_id: structure.slug, id: subscription.id,
    #     cancelation_reason_other: cancelation_reason
    #
    #   subscription.reload
    #
    #   expect(subscription.cancelation_reason_other).to eq(cancelation_reason)
    # end

    it 'redirects to the plans page' do
      delete :destroy, structure_id: structure.slug, id: subscription.id

      expect(response).to redirect_to(action: :index, structure_id: structure.slug)
    end
  end

  describe 'activate' do
    it 'activates the subscription'
    it 'redirects to the subscription detail page'
  end

  describe 'choose_new_plan' do
    it 'renders the choose_new_plan template'
    it 'assigns the subscriptions'
    it 'renders without a layout if it is a xhr request'
  end

  describe '#change_plan' do
    it 'changes the plan'
    it 'redirects to the index page'
  end

  describe '#reactivate' do
    it 'reactivates the subscription'
    it 'redirects to the index page'
  end

  describe '#accept_payments' do
    let!(:subscription) { plan.create_subscription!(structure) }
    let(:legal_entity)  { create_legal_entity(structure) }
    let(:bank_token) do
      StripeMock.generate_bank_token({
        bank_account: { country: 'FR', account_number: '000123456789', currency: 'EUR' }
      })
    end

    context 'without a bank token' do
      subject do
        patch :accept_payments, structure_id: structure.id, id: subscription.id,
          subscription: { legal_entity: legal_entity }
      end

      it "doesn't create a managed account" do
        subject

        structure.reload

        expect(structure.stripe_managed_account_id).to be_nil
        expect(structure.stripe_managed_account).to be_nil
      end

      it 'redirects to the home page' do
        subject

        structure.reload

        expect(response).to redirect_to(action: :index, structure_id: structure.slug)
      end
    end

    context 'with a bank token' do
      it 'creates a managed account' do
        patch :accept_payments, structure_id: structure.id, id: subscription.id,
          subscription: { stripe_bank_token: bank_token }

        structure.reload

        expect(structure.stripe_managed_account_id).to_not be_nil
        expect(structure.stripe_managed_account).to be_a(Stripe::Account)
        expect(structure.stripe_managed_account_secret_key).to_not be_nil
        expect(structure.stripe_managed_account_publishable_key).to_not be_nil
      end

      it 'redirects to the home page' do
        patch :accept_payments, structure_id: structure.id, id: subscription.id,
          subscription: { stripe_bank_token: bank_token, legal_entity: legal_entity }

        expect(response).to redirect_to(action: :index, structure_id: structure.slug)
      end
    end

  end
end
