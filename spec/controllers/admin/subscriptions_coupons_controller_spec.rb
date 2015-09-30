require 'rails_helper'
require 'stripe_mock'

describe Admin::SubscriptionsCouponsController, with_stripe: true do
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

    context 'when there are no coupons' do
      it 'renders the empty coupons partial' do
        get :index

        expect(response).to render_template(partial: '_coupons_empty')
      end
    end

    context 'when there are coupons' do
      let!(:coupons) do
        [ FactoryGirl.create(:subscriptions_coupon),
          FactoryGirl.create(:subscriptions_coupon) ]
      end

      it 'renders the list of coupons' do
        get :index

        expect(response).to render_template(partial: '_coupons_list')
      end
    end
  end

  describe '#new' do
    render_views

    it 'renders the new template' do
      get :new

      expect(response).to render_template('new')
    end

    it 'assigns a new coupon' do
      get :new

      expect(assigns(:coupon)).to be_a_new(Subscriptions::Coupon)
    end

    it 'renders the edition form' do
      get :new

      expect(response).to render_template(partial: '_form')
    end
  end
end
