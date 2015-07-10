class Guide::AnswerSerializer < ActiveModel::Serializer
  delegate :attributes, to: :object
end
