class NexmoClientFactory
  def self.client(options = nil)
    if Rails.env.production?
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
