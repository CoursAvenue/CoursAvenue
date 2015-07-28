require 'rails_helper'

RSpec.describe Community::Membership, type: :model, community: true do
  context 'associations' do
    it { should belong_to(:community) }
    it { should belong_to(:user) }
  end
end
