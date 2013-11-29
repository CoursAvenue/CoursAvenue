class PlaceSerializer < ActiveModel::Serializer
    attributes :id
    has_one :location
end
