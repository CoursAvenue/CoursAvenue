require 'rails_helper'

describe Pro::Structures::GiftCertificatesController, type: :controller do
  include Devise::TestHelpers

  before do
    sign_in admin
  end

  it { should use_before_action(:authenticate_pro_admin!) }
  it { should use_before_action(:set_structure) }

  let!(:structure) { FactoryGirl.create(:structure_with_admin, :with_contact_email) }
  let!(:admin)     { structure.main_contact }
  let!(:plan)      { FactoryGirl.create(:subscriptions_plan, :monthly, :module) }

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
end
