if ENV['REDIS_URL'].present?
  Split.redis = ENV['REDIS_URL']
end
