require 'rails_helper'

RSpec.describe Guide, type: :model, user_guide: true do
  context 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
  end

  context 'associations' do
    it { should have_many(:questions).class_name('Guide::Question') }
    it { should have_many(:answers).class_name('Guide::Answer') }
  end
end
