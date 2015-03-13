class CloseioFactory
  def self.client
    if Rails.env.test?
      FakeCloseio::Client.new
    else
      Closeio::Client.new(ENV['CLOSE_IO_API_KEY'])
    end
  end
end
