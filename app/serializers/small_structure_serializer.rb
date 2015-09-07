class SmallStructureSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  cached
  # Make sure to update the version when updating the serializer attributes / methods.
  def cache_key
    'SmallStructureSerializer/' + object.cache_key + '/v1'
  end

  attributes :id, :name, :slug, :latitude, :longitude

end
