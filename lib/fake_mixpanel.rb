module FakeMixpanel
  class Tracker
    def initialize(token = nil)
      Rails.logger.debug "[FakeMixpanel][initialize] Initialized with token #{token}."
    end

    def track(event, data = nil)
      Rails.logger.debug "[FakeMixpanel][Track] Event: '#{event}', data: #{data}"
    end
  end
end
