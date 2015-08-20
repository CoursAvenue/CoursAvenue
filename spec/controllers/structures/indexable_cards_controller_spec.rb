require 'rails_helper'

describe Structures::IndexableCardsController do
  include Devise::TestHelpers

  describe 'POST #toggle_favorite' do
    let(:user) { FactoryGirl.create(:user) }
    let(:card) { FactoryGirl.create(:indexable_card) }

    context 'when the user is not connected' do
      it 'does nothing' do
        expect { post :toggle_favorite, { id: card.id, structure_id: card.structure_id } }.
          to_not change { user.reload.favorites.count }
      end
    end

    context 'when the user is connected' do
      before { sign_in user }

      it 'toggles the favorite' do
        expect { post :toggle_favorite, { id: card.id, structure_id: card.structure_id } }.
          to change { user.reload.favorites.count }
      end
    end
  end
end
