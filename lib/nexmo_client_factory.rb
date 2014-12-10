class NexmoClientFactory
  def self.client
    if Rails.env.production?
      Nexmo::Client.new
    else
      FakeNexmo::Client.new
    end
  end
end
