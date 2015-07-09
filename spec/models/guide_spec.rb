require 'rails_helper'

RSpec.describe Guide, type: :model, user_guide: true do
  context 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should accept_nested_attributes_for(:questions) }
  end

  context 'associations' do
    it { should have_many(:questions).class_name('Guide::Question') }
    it { should have_many(:answers).class_name('Guide::Answer').through(:questions) }
  end
end
