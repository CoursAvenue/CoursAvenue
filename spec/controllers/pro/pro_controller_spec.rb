require "rails_helper"

describe Pro::ProController do
  include Devise::TestHelpers

  let(:admin)     { FactoryGirl.create(:admin) }
  let(:structure) { admin.structure }

  before do
    sign_in admin
  end

  describe 'set_sponsorship_token' do
    controller(Pro::ProController) do
      def index
        render nothing: true
      end
    end

    context "when there's a sponsorship token" do
      let(:sponsorship_token) { Faker::Internet.password }

      context "in session" do
        it 'sets the sponsorship token in the structure' do
          get :index, {}, { sponsorship_token: sponsorship_token }

          expect(structure.reload.sponsorship_token).to eq(sponsorship_token)
        end
      end

      context "in params" do
        it 'sets the sponsorship token in the structure' do
          get :index, { sponsorship_token: sponsorship_token }

          expect(structure.reload.sponsorship_token).to eq(sponsorship_token)
        end
      end
    end

    context "when there's not a sponsorship token" do
      it 'does nothing' do
        expect { get :index }.to_not change { structure.reload.sponsorship_token }
      end
    end
  end
end
