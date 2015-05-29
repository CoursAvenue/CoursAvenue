require 'rails_helper'
require 'stripe_mock'

describe Pro::SubscriptionsPlansController, type: :controller, with_stripe: true do
  include Devise::TestHelpers

  let!(:admin)     { FactoryGirl.create(:super_admin) }

  before do
    sign_in admin
  end

  before { StripeMock.start }
  after  { StripeMock.stop }

  describe '#index' do
    render_views

    it 'renders the index template' do
      get :index

      expect(response).to render_template('index')
    end

    context 'when there are no plans' do
      it 'renders the empty plans partial' do
        get :index

        expect(response).to render_template(partial: '_plans_empty')
      end
    end

    context 'when there are plans' do
      let!(:monthly_plans) do
        [ FactoryGirl.create(:subscriptions_plan, :monthly),
          FactoryGirl.create(:subscriptions_plan, :monthly) ]
      end

      let!(:yearly_plans) do
        [ FactoryGirl.create(:subscriptions_plan, :yearly),
          FactoryGirl.create(:subscriptions_plan, :yearly) ]
      end

      it 'renders the list of plans' do
        get :index

        expect(response).to render_template(partial: '_plans_list')
      end

      it 'assigns the plans divided by interval' do
        get :index

        expect(assigns(:monthly_plans)).to eq(monthly_plans)
        expect(assigns(:yearly_plans)).to  eq(yearly_plans)
      end
    end
  end

  describe '#new' do
    render_views

    it 'renders the new template' do
      get :new

      expect(response).to render_template('new')
    end

    it 'assigns a new plan' do
      get :new

      expect(assigns(:plan)).to be_a_new(Subscriptions::Plan)
    end

    it 'renders the edition form' do
      get :new

      expect(response).to render_template(partial: '_form')
    end
  end
end
