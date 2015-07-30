require 'rails_helper'

RSpec.describe Community::Membership, type: :model, community: true do
  context 'associations' do
    it { should belong_to(:community) }
    it { should belong_to(:user) }
  end

  let(:user) { FactoryGirl.create(:user) }
  subject { FactoryGirl.create(:community_membership, user: user) }

  describe '#can_receive_notifications?' do
    context 'when the user opted out of emails' do
      before do
        user.community_notification_opt_in = false
        user.save
      end

      it { expect(subject.can_receive_notifications?).to be_falsy }
    end

    context 'when the user has received a notification in the last NOTIFICATION_FREE_PERIOD' do
      before do
        subject.last_notification_at = 3.days.ago
        subject.save
      end

      it { expect(subject.can_receive_notifications?).to be_falsy }
    end

    context "when the user has opted in and has not received a notification" do
      before do
        subject.last_notification_at = 11.days.ago
        subject.save
      end

      it { expect(subject.can_receive_notifications?).to be_truthy }
    end
  end
end
