class Guide::AnswerSerializer < ActiveModel::Serializer
  attributes *(Guide::Answer.attribute_names.map(&:to_sym) + [:subjects, :ponderation])

  delegate :ponderation, to: :object, allow_nil: true

  def subjects
    object.subjects.map do |subject|
      { id: subject.id, name: subject.name, slug: subject.slug, image: subject.image.url }
    end
  end

  def image
    object.image.url
  end
end
