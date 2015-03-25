module FakeMandrill
  class Client
    def initialize(options = nil)
      Rails.logger.debug "[FakeMandrill][initialize] Initialized with options #{options}."
    end

    def messages
      @client ||= MessagesClient.new
    end
  end

  class MessagesClient
    def send(message, async, ip_pool, send_at = nil)
      Rails.logger.debug "[FakeMandrill][messages][send] sending message with following informations:"
      Rails.logger.debug "[FakeMandrill][messages][send]   subject:    #{message[:subject]}"
      Rails.logger.debug "[FakeMandrill][messages][send]   from_email: #{message[:from_email]}"
      Rails.logger.debug "[FakeMandrill][messages][send]   from_name:  #{message[:from_name]}"
    end

    def info(message_id)
      Rails.logger.debug "[FakeMandrill][messages][info] info from email with id: #{message_id}"
    end
  end
end
