# Doesn't work on heroku since upgrade to Rails 4.1

# Rails.application.config.after_initialize do
#   ActiveRecord::Base.connection_pool.disconnect!

#   ActiveSupport.on_load(:active_record) do
#     if Rails.application.config.database_configuration
#       config = Rails.application.config.database_configuration[Rails.env]
#       config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
#       config['pool']              = ENV['DB_POOL']      || 3
#       ActiveRecord::Base.establish_connection(config)
#     end
#   end
# end
