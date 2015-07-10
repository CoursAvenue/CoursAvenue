class GuideSerializer < ActiveModel::Serializer
  delegate :attributes, to: :object

  has_many :questions, serializer: Guide::QuestionSerializer
  has_many :answers, serializer: Guide::AnswerSerializer
end
