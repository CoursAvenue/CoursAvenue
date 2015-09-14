class BaseSearch
  # TODO: Make sure the attributes are always in the same order and return the same string.
  def self.params_to_cache_key(params)
    params.sort.to_h.to_param
  end
end
