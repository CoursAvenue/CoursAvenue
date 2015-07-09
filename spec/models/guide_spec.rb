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

  describe 'GET #subjects' do
    subject { FactoryGirl.create(:guide) }
    let!(:questions) {
      3.times.map { FactoryGirl.create(:guide_question, :with_answers, guide: subject) }
    }

    it 'returns the subjects associated with the answers' do
      subjects = subject.answers.flat_map(&:subjects).uniq
      expect(subject.subjects).to match_array(subjects)
    end

  end
end
