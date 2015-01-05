class NexmoClientFactory
  def self.client(options = nil)
    if Rails.env.production? or (!Rails.env.test? and ENV['DONT_USE_FAKE_NEXMO'] == 'true')
      if options.nil?
        Nexmo::Client.new
      else
        Nexmo::Client.new(options)
      end
    else
      FakeNexmo::Client.new
    end
  end
end
