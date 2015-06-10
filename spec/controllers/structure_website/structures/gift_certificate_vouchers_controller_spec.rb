require 'rails_helper'

describe StructureWebsite::Structures::GiftCertificateVouchersController, with_stripe: true do
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
      get :index, structure_id: structure.id
      expect(assigns(:gift_certificates)).to eq(structure.gift_certificates)
    end

    it 'builds a new voucher' do
      get :index, structure_id: structure.id
      expect(assigns(:voucher)).to be_a_new(GiftCertificate::Voucher)
    end

    it 'renders the index template' do
      get :index, structure_id: structure.id
      expect(response).to render_template('index')
    end
  end

  describe 'POST #create' do
    render_views

    let(:gifter)           { FactoryGirl.create(:user) }
    let(:gifted_to)        { Faker::Internet.email }
    let(:gift_certificate) { structure.gift_certificates.sample }
    let(:valid_params) do
      { structure_id: structure.id,
        gift_certificate_voucher:
          { gift_certificate_id: gift_certificate.id,
            name: Faker::Name.name,
            email: Faker::Internet.email }
      }
    end

    it 'creates a voucher' do
      expect { post :create, valid_params }.
        to change { GiftCertificate::Voucher.count }.by(1)
    end

    it 'redirects to the index page' do
      post :create, valid_params
      created_voucher = GiftCertificate::Voucher.last
      expect(response)
        .to redirect_to(structure_website_structure_gift_certificate_vouchers_path(structure))
    end

    it 'sends an email to theacher and the gifter', with_mail: true do
      expect { post :create, valid_params }.
        to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end
end
