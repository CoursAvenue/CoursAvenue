require 'rails_helper'

describe Community::Notifier, community: true, with_mail: true do
  let!(:structure)  { FactoryGirl.create(:structure_with_admin) }
  let!(:community)  { FactoryGirl.create(:community, structure: structure) }
  let!(:user)       { FactoryGirl.create(:user) }
  let!(:membership) { FactoryGirl.create(:community_membership, user: user) }
  let!(:message)    { Faker::Lorem.paragraph(10) }
  let!(:thread)     { community.ask_question!(user, Faker::Lorem.paragraph(5)) }

  describe '#notify_admin' do
    subject { Community::Notifier.new(thread, message, membership) }

    it 'sends an email to the admin' do
      expect(CommunityMailer).to receive(:notify_admin_of_question).once
      subject.notify_admin
    end
  end

  describe '#notify_members' do
    subject { Community::Notifier.new(thread, message, membership) }

    it 'sends an email to ten members of the community who can receive notifications' do
      5.times do
        user = FactoryGirl.create(:user)
        membership = community.memberships.create(user: user)
      end

      expect(CommunityMailer).to receive(:notify_member_of_question).exactly(6).times
      subject.notify_members
    end
  end

  describe '#notify_answer_from_teacher' do
    subject { Community::Notifier.new(thread, message, membership) }

    before do
      3.times do
        user = FactoryGirl.create(:user)
        thread.reply!(user, Faker::Lorem.paragraph(10))
      end
    end

    it 'sends an email to every participant of the thread' do
      expect(CommunityMailer).to receive(:notify_answer_from_teacher).exactly(4).times
      subject.notify_answer_from_teacher
    end
  end

  describe '#notify_answer_from_member' do
    subject { Community::Notifier.new(thread, message, membership) }

    before do
      3.times do
        user = FactoryGirl.create(:user)
        thread.reply!(user, Faker::Lorem.paragraph(10))
      end
    end

    it 'sends an email to every participant of thread except the one that replied' do
      expect(CommunityMailer).to receive(:notify_answer_from_member_to_teacher)
      subject.notify_answer_from_member
    end

    it 'sends an email to the teacher' do
      expect(CommunityMailer).to receive(:notify_answer_from_member_to_teacher).once
      subject.notify_answer_from_member
    end
  end
end
