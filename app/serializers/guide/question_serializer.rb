class Guide::QuestionSerializer < ActiveModel::Serializer
  delegate :attributes, to: :object

  cached
  def cache_key
    'Guide::QuestionSerializer/' + object.cache_key
  end

  has_many :answers, serializer: Guide::AnswerSerializer
end
