require 'rails_helper'

describe Guide::Importer, user_guide: true do
  let(:guide) { stub_create_guide }

  describe '#import' do
    it 'creates a guide' do
      serialized_guide = GuideSerializer.new(guide).to_json
      expect { Guide::Importer.new(serialized_guide).import }.to change { Guide.count }.by(1)
    end

    it 'creates the same questions as in the original guide' do
      serialized_guide = GuideSerializer.new(guide).to_json
      expect { Guide::Importer.new(serialized_guide).import }.
        to change { Guide::Question.count }.by(guide.questions.count)
    end

    it 'creates the same answers as in the origin guide' do
      serialized_guide = GuideSerializer.new(guide).to_json
      expect { Guide::Importer.new(serialized_guide).import }.
        to change { Guide::Answer.count }.by(guide.answers.count)
    end
  end

  def stub_create_guide(question_count = 3)
    guide = FactoryGirl.create(:guide)
    question_count.times do
      question = FactoryGirl.create(:guide_question, :with_answers)
    end

    guide.reload
  end
end
