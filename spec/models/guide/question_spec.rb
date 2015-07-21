require 'rails_helper'

RSpec.describe Guide::Question, type: :model, user_guide: true do
  context 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:ponderation) }
    it { should accept_nested_attributes_for(:answers) }
  end

  context 'assocations' do
    it { should belong_to(:guide) }
    it { should have_many(:answers).class_name('Guide::Answer') }
  end
end
