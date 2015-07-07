require 'rails_helper'

RSpec.describe Guide::Answer, type: :model, user_guide: true do
  context 'validations' do
    it { should validate_presence_of(:content) }
  end

  context 'assocations' do
    it { should belong_to(:guide) }
    it { should belong_to(:question).class_name('Guide::Question') }
  end
end
