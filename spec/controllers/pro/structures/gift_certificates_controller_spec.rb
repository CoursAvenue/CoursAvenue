require 'rails_helper'

describe Pro::Structures::GiftCertificatesController, type: :controller do
  include Devise::TestHelpers

  before do
    sign_in admin
  end

  it { should use_before_action(:authenticate_pro_admin!) }
  it { should use_before_action(:set_structure) }

  let!(:structure)    { FactoryGirl.create(:structure_with_admin, :with_contact_email) }
  let!(:subscription) { FactoryGirl.create(:subscription, :canceled, structure: structure) }
  let!(:admin)        { structure.main_contact }
  let!(:plan)         { FactoryGirl.create(:subscriptions_plan, :monthly, :module) }

  describe '#index' do
    render_views

    it 'renders the index template' do
      get :index, structure_id: structure.slug

      expect(response).to render_template('index')
    end

    context "when the structure is not premium" do
      it 'renders the subscription partial' do
        get :index, structure_id: structure.slug
        expect(response).to render_template(partial: '_subscribe')
      end
    end

    context 'when the structure is premium' do
      before do
        allow_any_instance_of(Structure).to receive(:premium?).and_return(true)
      end

      context "when there aren't any gift certificates" do
        it 'renders the empty list partial' do
          get :index, structure_id: structure.slug

          expect(response).to render_template(partial: '_gift_certificates_empty')
        end
      end

      context 'when there are gift certificates' do
        before do
          structure.gift_certificates << FactoryGirl.create(:gift_certificate, structure: structure)
          structure.gift_certificates << FactoryGirl.create(:gift_certificate, structure: structure)
          structure.gift_certificates << FactoryGirl.create(:gift_certificate, structure: structure)
        end

        it 'assigns the gift certificates' do
          get :index, structure_id: structure.slug

          expect(assigns(:gift_certificates)).to match_array(structure.gift_certificates)
        end

        it 'renders the gift certificates list' do
          get :index, structure_id: structure.slug

          expect(response).to render_template(partial: '_gift_certificates_list')
        end
      end
    end
  end

  describe '#new' do
    render_views

    it 'renders the new template' do
      get :new, structure_id: structure.slug

      expect(response).to render_template('new')
    end

    it 'renders the edition form partial' do
      get :new, structure_id: structure.slug

      expect(response).to render_template(partial: '_form')
    end

    it 'assigns a new gift certificate' do
      get :new, structure_id: structure.slug

      expect(assigns(:gift_certificate)).to be_a_new(GiftCertificate)
    end

    context 'when xhr request' do
      it "doens't render the layout" do
        xhr :get, :new, structure_id: structure.id

        expect(response).to_not render_with_layout('admin')
      end
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      let(:gift_certificate_attributes) {
        { gift_certificate: FactoryGirl.build(:gift_certificate).attributes }
      }

      it 'creates a new Gift Certificate' do
        expect {
          post :create, { structure_id: structure.id }.merge(gift_certificate_attributes)
        }.to change { GiftCertificate.count }.by(1)
      end

      it 'redirect to the index page' do
        post :create, { structure_id: structure.id }.merge(gift_certificate_attributes)

        expect(response).to redirect_to(action: :index, structure_id: structure.slug)
      end
    end

    context 'with missing attributes' do
      it "doesn't create a new Gift Certificate" do
        expect {
          post :create, { structure_id: structure.id, gift_certificate: { name: Faker::Name.name } }
        }.to_not change { GiftCertificate.count }
      end

      it 're-renders the :new action' do
        post :create, { structure_id: structure.id, gift_certificate: { name: Faker::Name.name } }

        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    let(:gift_certificate) { FactoryGirl.create(:gift_certificate, structure: structure) }
    context 'with valid attributes' do
      let(:updated_name)     { gift_certificate.name + ' updated'}
      let(:gift_certificate_attributes) {
        { gift_certificate: { name: updated_name } }
      }

      it 'updates the gift certificate' do
        patch :update, { structure_id: structure.id, id: gift_certificate.id }.
          merge(gift_certificate_attributes)

        gift_certificate.reload
        expect(gift_certificate.name).to eq(updated_name)
      end

      it 'redirect to the index page' do
        patch :update, { structure_id: structure.id, id: gift_certificate.id }.
          merge(gift_certificate_attributes)

        expect(response).to redirect_to(action: :index, structure_id: structure.slug)
      end
    end

    context 'with missing attributes' do
      let(:updated_name) { '' }
      let(:gift_certificate_attributes) {
        { gift_certificate: { name: updated_name } }
      }

      it "doesn't create a new Gift Certificate" do
        current_name = gift_certificate.name
        patch :update, { structure_id: structure.id, id: gift_certificate.id }.
          merge(gift_certificate_attributes)

        gift_certificate.reload
        expect(gift_certificate.name).to eq(current_name)
        expect(gift_certificate.name).to_not eq(updated_name)
      end

      it 're-renders the :new action' do
        patch :update, { structure_id: structure.id, id: gift_certificate.id }.
          merge(gift_certificate_attributes)

        expect(response).to render_template(:new)
      end
    end

  end

  describe '#destroy' do
    let(:gift_certificate) { FactoryGirl.create(:gift_certificate, structure: structure) }

    it 'deletes the gift certificate' do
      delete :destroy, id: gift_certificate.id, structure_id: structure.slug

      gift_certificate.reload
      expect(gift_certificate.deleted_at).to_not be_nil
    end
  end

  describe '#install_guide' do
    render_views

    it 'renders the install_guide template' do
      get :install_guide, structure_id: structure.slug

      expect(response).to render_template('install_guide')
    end

    context 'when xhr request' do
      it "doens't render the layout" do
        xhr :get, :install_guide, structure_id: structure.id

        expect(response).to_not render_with_layout('admin')
      end
    end
  end
end
