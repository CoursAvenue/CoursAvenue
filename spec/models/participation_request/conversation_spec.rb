require 'rails_helper'

RSpec.describe ParticipationRequest::Conversation, type: :model do
  context 'associations' do
    it { should belong_to(:participation_request) }
    it { should belong_to(:mailboxer_conversation) }
  end

  describe '#send_request!' do
    context 'when the message is not present' do
      it 'return false' do
        conversation = FactoryGirl.build_stubbed(:participation_request_conversation)
        expect(conversation.send_request!(nil)).to eq(false)
      end
    end

    it 'creates a maiboxer conversation' do
      structure = FactoryGirl.create(:structure_with_admin)
      pr = FactoryGirl.create(:participation_request, structure: structure)
      conversation = FactoryGirl.create(:participation_request_conversation,
                                        participation_request: pr)
      message = Faker::Lorem.paragraph(2)

      expect { conversation.send_request!(message) }.
        to change { Mailboxer::Conversation.count }.by(1)
    end

    it 'saves the conversation' do
      structure = FactoryGirl.create(:structure_with_admin)
      pr = FactoryGirl.create(:participation_request, structure: structure)
      conversation = FactoryGirl.create(:participation_request_conversation,
                                        participation_request: pr)
      message = Faker::Lorem.paragraph(2)

      conversation.send_request!(message)
      expect(conversation.mailboxer_conversation).to be_a(Mailboxer::Conversation)
    end
  end

  describe 'reply!' do
    context 'when the params are not valid' do
      it 'does not add a message to the conversation' do
        structure = FactoryGirl.create(:structure_with_admin)
        pr = FactoryGirl.create(:participation_request, structure: structure)
        conversation = FactoryGirl.create(:participation_request_conversation,
                                          participation_request: pr)

        message = Faker::Lorem.paragraph
        conversation.send_request!(message)

        expect { conversation.reply!(nil, nil) }.to_not change { conversation.messages.count }
      end
    end

    it 'adds a message to the conversation' do
      structure = FactoryGirl.create(:structure_with_admin)
      pr = FactoryGirl.create(:participation_request, structure: structure)
      conversation = FactoryGirl.create(:participation_request_conversation,
                                        participation_request: pr)
      message = Faker::Lorem.paragraph
      reply = Faker::Lorem.paragraph

      conversation.send_request!(message)

      expect { conversation.reply!(reply, 'Structure') }.
        to change { conversation.messages.count }.by(1)
    end
  end
end
