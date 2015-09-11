module FakeNexmo
  class Client
    def initialize(options = nil)
      Rails.logger.debug "[FakeNexmo][initialize] Initialized with options #{options}."
    end

    def send_message(options)
      Rails.logger.debug "[FakeNexmo][send_message] from: #{options[:from]}, \
      to: #{options[:to]}, message: #{options[:message]}"
    end

    def get_message(id)
      Rails.logger.debug "[FakeNexmo][get_message] checking message #{ id }"
      { id: id }
    end
  end
end
