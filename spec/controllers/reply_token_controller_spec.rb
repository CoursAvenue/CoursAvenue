# -*- encoding : utf-8 -*-
require 'rails_helper'

describe ReplyTokenController, type: :controller do
  describe '#show' do
    context 'with wrong user agent' do
      it 'is unauthorized' do
        get :show, id: Faker::Internet.password

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with the right user agent' do

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return(
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/1.0 (KHTML, like Gecko; Gmail Actions)')
      end

      # context 'bad request' do
      #   let(:token) { FactoryGirl.create(:reply_token) }
      #
      #   it 'returns 400' do
      #     get :show, id: token.id
      #
      #     expect(response).to have_http_status(400)
      #   end
      # end

      context 'unauthorized request' do
        let(:token) { FactoryGirl.create(:reply_token) }

        before do
          token.use!
        end

        it 'returns 401' do
          get :show, id: token.id

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'not found request' do
        it 'returns 404' do
          get :show, id: Faker::Internet.password

          expect(response).to have_http_status(:not_found)
        end
      end

      # context 'request timeout' do
      #   let(:token) { FactoryGirl.create(:reply_token) }
      #
      #   it 'returns 408' do
      #   end
      # end

      context 'everything good' do
        let(:token) { FactoryGirl.create(:reply_token) }

        before do
          participation_request            = ParticipationRequest.find token.participation_request_id
          participation_request.state      = 'accepted'
          participation_request.start_time = 2.days.from_now

          participation_request.save
        end

        it 'returns 200' do
          get :show, id: token.id

          expect(response).to have_http_status(:ok)
        end

        it 'consumes the token' do
          get :show, id: token.id

          expect(token.still_valid?).to be false
        end
      end
    end
  end
end
