class GuideSerializer < ActiveModel::Serializer
  # This allows us to have all of the Guide attributes and to add some.
  attributes *(Guide.attribute_names.map(&:to_sym) + [:subjects])

  delegate :attributes, to: :object

  has_many :questions, serializer: Guide::QuestionSerializer
  has_many :answers, serializer: Guide::AnswerSerializer

  def subjects
    object.subjects.map do |subject|
      { id: subject.id,
        name: subject.name,
        slug: subject.slug,
        root_slug: subject.root.slug,
        guide_description: subject.guide_description,
        advices: [
          { id: 'younger-than-5', title: 'Conseils pour les enfants de moins de 5 ans',
            content: subject.age_advice_younger_than_5 },
          { id: 'between-5-and-9', title: 'Conseils pour les enfants entre 5 et 9 ans',
            content: subject.age_advice_between_5_and_9 },
          { id: 'older-than-10', title: 'Conseils pour les enfants de plus de 10 ans',
            content: subject.age_advice_older_than_10 },
        ]
      }
    end
  end
end
