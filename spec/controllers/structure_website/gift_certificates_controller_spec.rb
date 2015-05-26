require 'rails_helper'

describe StructureWebsite::GiftCertificatesController, with_stripe: true do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  let!(:structure)    { FactoryGirl.create(:structure_with_admin) }
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:token)         { stripe_helper.generate_card_token }
  let(:plan)          { FactoryGirl.create(:subscriptions_plan, :monthly) }
  let(:subscription)  { plan.create_subscription!(structure) }

  before(:each) do
    subscription.charge!(token)
    5.times.map { FactoryGirl.create(:gift_certificate, structure: structure) }
    @request.host = "#{structure.slug}.example.com"
    structure.reload
  end

  describe 'GET #index' do
    render_views

    it 'assigns all of the gift certificates' do
      get :index
      expect(assigns(:gift_certificates)).to eq(structure.gift_certificates)
    end

    it 'builds a new voucher' do
      get :index
      expect(assigns(:voucher)).to be_a_new(GiftCertificate::Voucher)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET #show' do
    it 'assign the voucher'
    it 'renders the show template'
  end

  describe 'POST #create' do
    let(:gifter)           { FactoryGirl.create(:user) }
    let(:gifted_to)        { Faker::Internet.email }
    let(:gift_certificate) { structure.gift_certificates.sample }
    let(:valid_params) do
      { gift_certificate_voucher:
        { user_id: gifter.id,
          gifted_to: gifted_to,
          gift_certificate_id: gift_certificate.id }
      }
    end

    it 'creates a voucher' do
      expect { post :create, valid_params }.
        to change { GiftCertificate::Voucher.count }.by(1)
    end

    it 'redirects to the index page' do
      post :create, valid_params

      expect(response).to redirect_to(action: :index)
    end

    it 'sends an email to theacher', with_mail: true do
      expect { post :create, valid_params }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
