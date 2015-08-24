require 'rails_helper'

describe Structures::IndexableCards::FavoriteController do
  include Devise::TestHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:card) { FactoryGirl.create(:indexable_card) }
  let(:params) { { indexable_card_id: card.id, structure_id: card.structure_id, format: :json } }

  describe 'POST #create' do
    context 'when the user is not connected' do
      it 'does nothing' do
        expect { post :create, params }.
          to_not change { user.reload.favorites.count }
      end
    end

    context 'when the user is connected' do
      before { sign_in user }

      it 'creates the favorite' do
        expect { post :create, params }.
          to change { user.reload.favorites.count }.by(1)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is not connected' do
      it 'does nothing' do
        expect { delete :destroy, params }.
          to_not change { user.reload.favorites.count }
      end
    end

    context 'when the user is connected' do
      before { sign_in user }

      it 'creates the favorite' do
        user.favorites.create(indexable_card: card)
        expect { delete :destroy, params }.
          to change { user.reload.favorites.count }.by(-1)
      end
    end
  end
end
