class Guide::QuestionSerializer < ActiveModel::Serializer
  delegate :attributes, to: :object

  has_many :answers, serializer: Guide::AnswerSerializer
end
