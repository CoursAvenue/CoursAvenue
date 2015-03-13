module FakeCloseio
  class Client
    def initialize(options = nil)
      Rails.logger.debug "[FakeCloseio][initialize] Initialized with options #{options}."
    end

    def list_leads(options)
      Rails.logger.debug "[FakeCloseio][list_leads] #{options}"
      {
        'data' => []
      }
    end

    def update_lead(options)
      Rails.logger.debug "[FakeCloseio][update_lead] #{options}"
      {
        'errors' => []
      }
    end

    def create_lead(options)
      Rails.logger.debug "[FakeCloseio][create_lead] #{options}"
      {
        'errors' => []
      }
    end
  end
end

