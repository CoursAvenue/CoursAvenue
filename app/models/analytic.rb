class Analytic
  # Add dimensions and metrics in GA dashboard.
  DIMENSIONS = %w(structure)              # Index base should be 1
  METRICS    = %w(impression view action) # Index base should be 1

  def self.client
    Analytic::Client.new
  end
end
