# -*- encoding : utf-8 -*-
require 'rails_helper'

describe ReplyTokenController, type: :controller do
  describe '#show' do
    context 'with wrong user agent' do
      it 'is unauthorized' do
        get :show, id: Faker::Number.number(2)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
