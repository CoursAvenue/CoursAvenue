require 'rails_helper'
require 'stripe_mock'

RSpec.describe Pro::Structures::SubscriptionsController, type: :controller do
  include Devise::TestHelpers

  let!(:structure) { FactoryGirl.create(:structure_with_admin, :with_contact_email) }
  let!(:admin)     { structure.main_contact }

  before do
    sign_in admin
  end

  before { StripeMock.start }
  after  { StripeMock.stop }

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

      let!(:subscription) { create_subscription(structure) }

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
end

def create_subscription(structure)
  stripe_helper = StripeMock.create_test_helper
  plan          = FactoryGirl.create(:subscriptions_plan)
  token         = stripe_helper.generate_card_token

  stripe_helper.create_plan(id: plan.stripe_plan_id, amount: plan.amount, currency: 'EUR')
  subscription = plan.create_subscription!(structure, token)

  subscription
end
