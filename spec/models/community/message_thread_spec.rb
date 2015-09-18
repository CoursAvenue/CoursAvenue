require 'rails_helper'

RSpec.describe Community::MessageThread, type: :model, community: true do
  context 'associations' do
    it { should belong_to(:community) }
    it { should belong_to(:membership).class_name('Community::Membership').
         with_foreign_key('community_membership_id') }
    it { should belong_to(:conversation).class_name('Mailboxer::Conversation').
         with_foreign_key('mailboxer_conversation_id') }
  end

  let(:structure)  { FactoryGirl.create(:structure_with_admin) }
  let(:community)  { FactoryGirl.create(:community, structure: structure) }
  let(:user)       { FactoryGirl.create(:user) }
  let(:membership) { FactoryGirl.create(:community_membership, user: user) }
  let(:message)    { Faker::Lorem.paragraph(10) }

  subject { FactoryGirl.create(:community_message_thread, community: community, membership: membership) }

  describe 'send_message!' do
    it 'creates a maiboxer conversation' do
      expect { subject.send_message!(message) }.
        to change { Mailboxer::Conversation.count }.by(1)
    end

    it 'saves the conversation' do
      subject.send_message!(message)
      expect(subject.conversation).to be_a(Mailboxer::Conversation)
    end
  end

  describe 'reply!' do

    subject { community.ask_question!(user, Faker::Lorem.paragraph(10)) }

    context 'when the replier is a user' do
      let(:user1)    { FactoryGirl.create(:user) }
      let(:message) { Faker::Lorem.paragraph(10) }

      it 'adds a message to the conversation' do
        expect { subject.reply!(user1, message) }.
          to change { subject.conversation.messages.count }.by(1)
      end
    end

    context "when the replier is the structure's admin" do
      let(:admin)   { structure.admin }
      let(:message) { Faker::Lorem.paragraph(10) }

      it 'adds a message to the conversation' do
        expect { subject.reply!(admin, message) }.
          to change { subject.conversation.messages.count }.by(1)
      end
    end

  end

  describe 'approve!' do
    context 'when it was not already approved' do
      it 'doesn not do anything' do
        thread = community.ask_question!(user, Faker::Lorem.paragraph(10))
        thread.approved = true
        thread.save

        expect(thread.approve!).to be_falsy
      end
    end

    it 'approves the thread' do
      thread = community.ask_question!(user, Faker::Lorem.paragraph(10))
      expect { thread.approve! }.to change { thread.approved }.from(false).to(true)
    end

    # it 'notifies the admin' do
    #   expect_any_instance_of(Community::Notifier).to receive(:notify_admin)
    #   thread = community.ask_question!(user, Faker::Lorem.paragraph(10))
    #   thread.approve!
    # end

    it 'notifies the community members' do
      expect_any_instance_of(Community::Notifier).to receive(:notify_members)
      thread = community.ask_question!(user, Faker::Lorem.paragraph(10))
      thread.approve!
    end
  end

  describe '#participants' do
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:user3) { FactoryGirl.create(:user) }

    subject { community.ask_question!(user, Faker::Lorem.paragraph(10)) }

    before do
      subject.reply!(user1, message)
      subject.reply!(user2, message)
      subject.reply!(user3, message)
    end

    it 'returns the memberships of every participants to the thread' do
      participants = subject.participants
      expect(participants.map(&:user)).to match_array([user, user1, user2, user3])
    end
  end
end
