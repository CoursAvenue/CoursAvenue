require 'rails_helper'

RSpec.describe Community, type: :model, community: true do
  context 'association' do
    it { should belong_to(:structure) }
    it { should have_many(:memberships).class_name('Community::Membership') }
    it { should have_many(:users).through(:memberships) }
  end
end
