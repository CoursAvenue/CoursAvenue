Rails.application.middleware.tap do |middleware|
  middleware.delete ActiveRecord::Migration::CheckPending
end
