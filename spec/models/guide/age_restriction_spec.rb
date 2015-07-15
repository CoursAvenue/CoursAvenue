require 'rails_helper'

RSpec.describe Guide::AgeRestriction, type: :model, user_guide: true do
  context 'associations' do
    it { should belong_to(:guide) }
  end

  context 'validations' do
    subject { Guide::AgeRestriction.new }

    it 'fails the save' do
      subject.save
      expect(subject.errors).to_not be_empty
    end
  end
end
