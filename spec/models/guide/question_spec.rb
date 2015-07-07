require 'rails_helper'

RSpec.describe Guide::Question, type: :model, user_guide: true do
  context 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:ponderation) }
  end

  context 'assocations' do
    it { should belong_to(:guide) }
  end
end
