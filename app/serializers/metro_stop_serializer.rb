class MetroStopSerializer < ActiveModel::Serializer

  cached
  def cache_key
    'MetroStopSerializer/' + object.cache_key
  end

  attributes :name, :latitude, :longitude

  has_many :lines, serializer: MetroLineSerializer

end
