require 'rails_helper'

RSpec.describe Guide::Answer, type: :model, user_guide: true do
  context 'validations' do
    it { should validate_presence_of(:content) }
  end

  context 'assocations' do
    it { should belong_to(:question).class_name('Guide::Question') }
    it { should have_one(:guide).through(:question) }
    it { should have_and_belong_to_many(:subjects) }
  end

  context 'delegations' do
    it { should delegate_method(:ponderation).to(:question).allow_nil(true) }
  end
end
