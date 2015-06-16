class IntercomClientFactory
  def self.client
    Intercom::Client.new(app_id: ENV['INTERCOM_APP_ID'], api_key: ENV['INTERCOM_API_KEY'])
  end
end
