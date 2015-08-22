class Guide::AnswerSerializer < ActiveModel::Serializer
  delegate :ponderation, to: :object, allow_nil: true

  cached
  def cache_key
    'Guide::AnswerSerializer/' + object.cache_key
  end

  attributes *(Guide::Answer.attribute_names.map(&:to_sym) + [:subjects, :ponderation])

  def subjects
    object.subjects.map do |subject|
      { id: subject.id, name: subject.name, slug: subject.slug, image: subject.image.url }
    end
  end

  def image
    object.image.url
  end
end
