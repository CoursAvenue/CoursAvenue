class MetroStopSerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  attributes :name, :latitude, :longitude

  has_many :lines, serializer: MetroLineSerializer

end
