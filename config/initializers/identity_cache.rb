if Rails.env.production?
  IdentityCache.cache_backend = ActiveSupport::Cache.lookup_store(*Rails.configuration.identity_cache_store)
end
