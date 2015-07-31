require 'spec_helper'

describe Community::Notifier, community: true do
  let(:structure)  { FactoryGirl.create(:structure_with_admin) }
  let(:community)  { FactoryGirl.create(:community, structure: structure) }
  let(:user)       { FactoryGirl.create(:user) }
  let(:membership) { FactoryGirl.create(:community_membership, user: user) }
  let(:message)    { Faker::Lorem.paragraph(10) }
  let(:thread)     { FactoryGirl.create(:community_message_thread, community: community, membership: membership) }

  subject { Community::Notifier.new(thread, message, membership) }
  describe '#notify_question' do
    it 'sends an email to the teacher'

    it 'sends an email to ten members of the community who can receive notifications'
  end
end
