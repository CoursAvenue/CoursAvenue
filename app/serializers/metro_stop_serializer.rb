class MetroStopSerializer < ActiveModel::Serializer

  attributes :name, :latitude, :longitude

  has_many :lines, serializer: MetroLineSerializer

end
