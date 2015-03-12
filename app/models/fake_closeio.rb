module FakeCloseio
  class Client
    def initialize(options = nil)
      Rails.logger.debug "[FakeCloseio][initialize] Initialized with options #{options}."
    end

    def update(structure)
      Rails.logger.debug "[FakeCloseio][update] #{structure.name}"
    end
  end
end
