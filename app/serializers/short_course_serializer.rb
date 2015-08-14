class ShortCourseSerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  attributes :id, :name
end
