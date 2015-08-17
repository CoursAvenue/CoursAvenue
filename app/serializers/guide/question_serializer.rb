class Guide::QuestionSerializer < ActiveModel::Serializer
  delegate :attributes, to: :object

  cached
  delegate :cache_key, to: :object

  has_many :answers, serializer: Guide::AnswerSerializer
end
