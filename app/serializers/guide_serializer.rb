class GuideSerializer < ActiveModel::Serializer
  # This allows us to have all of the Guide attributes and to add some.
  attributes *(Guide.attribute_names.map(&:to_sym) + [:subjects])

  delegate :attributes, to: :object

  has_many :questions, serializer: Guide::QuestionSerializer
  has_many :answers, serializer: Guide::AnswerSerializer

  def subjects
    object.subjects.map do |subject|
      { id: subject.id,
        slug: subject.slug,
        name: subject.name,
        guide_description: subject.guide_description
      }
    end
  end
end
