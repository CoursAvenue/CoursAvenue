class GuideSerializer < ActiveModel::Serializer
  delegate :attributes, to: :object

  has_many :questions, serializer: Guide::QuestionSerializer
end
