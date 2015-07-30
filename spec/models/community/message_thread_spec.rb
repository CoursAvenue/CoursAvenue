require 'rails_helper'

RSpec.describe Community::MessageThread, type: :model, community: true do
  context 'associations' do
    it { should belong_to(:community) }
    it { should belong_to(:membership).class_name('Community::Membership').
         with_foreign_key('community_membership_id') }
    it { should belong_to(:conversation).class_name('Mailboxer::Conversation').
         with_foreign_key('mailboxer_conversation_id') }
  end

  let(:structure)  { FactoryGirl.create(:structure) }
  let(:community)  { FactoryGirl.create(:community, structure: structure) }
  let(:user)       { FactoryGirl.create(:user) }
  let(:membership) { FactoryGirl.create(:community_membership, user: user) }
  let(:message)    { Faker::Lorem.paragraph(10) }

  subject { FactoryGirl.create(:community_message_thread, community: community, membership: membership) }

  describe 'send_message!' do
    it 'creates a maiboxer conversation' do
      expect { subject.send_message!(message) }.
        to change { Mailboxer::Conversation.count }.by(1)
      expect(subject.conversation).to be_a(Mailboxer::Conversation)
    end
  end
end
