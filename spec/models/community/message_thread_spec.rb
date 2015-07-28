require 'rails_helper'

RSpec.describe Community::MessageThread, type: :model, community: true do
  context 'associations' do
    it { should belong_to(:community) }
    it { should belong_to(:membership).class_name('Community::Membership').
         with_foreign_key('community_membership_id') }
    it { should belong_to(:conversation).class_name('Mailboxer::Conversation').
         with_foreign_key('mailboxer_conversation_id') }
  end
end
