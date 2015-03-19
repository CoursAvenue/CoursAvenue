class CloseioFactory
  def self.client
    if Rails.env.production?
      Closeio::Client.new(ENV['CLOSE_IO_API_KEY'])
    else
      FakeCloseio::Client.new
    end
  end
end
