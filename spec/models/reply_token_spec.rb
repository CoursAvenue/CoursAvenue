require 'rails_helper'

RSpec.describe ReplyToken, :type => :model do
  context 'unique token' do
    let(:reply_token_1) { ReplyToken.create(reply_type: 'conversation') }

    it 'is not valid if the token already exists' do
      reply_token_2 = ReplyToken.create(token: reply_token_1.token, reply_type: 'conversation')

      expect(reply_token_2).to be_invalid
    end
  end
end
