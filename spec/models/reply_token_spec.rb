require 'rails_helper'

RSpec.describe ReplyToken, type: :model do
  context 'validation' do
    subject { ReplyToken.create(reply_type: 'conversation') }

    it 'generates the token' do
      expect(subject.token).to_not be_nil
    end
  end

  context 'unique token' do
    let(:reply_token_1) { ReplyToken.create(reply_type: 'conversation') }

    it 'is not valid if the token already exists' do
      reply_token_2 = ReplyToken.create(token: reply_token_1.token, reply_type: 'conversation')

      expect(reply_token_2).to be_invalid
    end
  end

  context '#still_valid?' do
    subject { ReplyToken.create(reply_type: 'participation_request') }

    context 'participation_request' do
      let(:participation_request) { FactoryGirl.create(:participation_request) }

      before do
        subject.data = {
          sender_type:              'user',
          sender_id:                participation_request.user.id,
          participation_request_id: participation_request.id
        }

        subject.save
      end

      context 'when the participation request is pending' do
        before do
          participation_request.state.accept!
          participation_request.save
        end

        it 'is not valid' do
          expect(subject.still_valid?).to be false
        end
      end

      context 'when the participation request is in the past' do
        before do
          participation_request.date = 2.days.ago
          participation_request.save
        end

        it 'is not valid' do
          expect(subject.still_valid?).to be false
        end
      end

      context "when it hasn't been used yet" do
        it "is valid when it hasn't been used yet" do
          expect(subject.still_valid?).to be true
        end
      end
    end

  end

  describe '#email_address' do
    it 'returns the token suffixed by the mail domain' do
      reply_token = ReplyToken.create(reply_type: 'comment')
      expected = "CoursAvenue <#{ reply_token.token }@#{CoursAvenue::Application::MANDRILL_REPLY_TO_DOMAIN}>"
      expect(reply_token.email_address).to eq(expected)
    end
  end
end
