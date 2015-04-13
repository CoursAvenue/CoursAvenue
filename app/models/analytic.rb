class Analytic
  # Add dimensions and metrics in GA dashboard.
  DIMENSIONS = %w(structure)              # Index base should be 1
  METRICS    = %w(impression view action) # Index base should be 1

  def self.client
    if Rails.env.test?
      Analytic::FakeClient.new
    else
      Analytic::Client.new
    end
  end
end
