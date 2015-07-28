require 'rails_helper'

RSpec.describe Community, type: :model, community: true do
  context 'association' do
    it { should belong_to(:structure) }
    it { should have_many(:message_threads).class_name('Community::MessageThread') }
    it { should have_many(:memberships).class_name('Community::Membership') }
    it { should have_many(:users).through(:memberships) }
  end

  describe '#ask_question!' do
    let(:user)      { FactoryGirl.create(:user) }
    let(:structure) { FactoryGirl.create(:structure) }
    let(:message)   { Faker::Lorem.paragraph }

    subject { FactoryGirl.create(:community, structure: structure) }

    context "when the user membership doesn't exists" do
      it 'creates a new membership' do
        expect { subject.ask_question!(user, structure, message) }.
          to change { Community::Membership.count }.by(1)
      end
    end

    context 'when the user has a membership' do
      it "doesn't create a new membership" do
        subject.memberships.create(user: user)
        expect { subject.ask_question!(user, structure, message) }.
          to_not change { Community::Membership.count }
      end
    end

    it 'returns a new message thread' do
      expect(subject.ask_question!(user, structure, message)).to be_a(Community::MessageThread)
    end
  end
end
