class MixpanelClientFactory
  def self.client
    if Rails.env.production?
      Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_TOKEN'])
    else
      FakeMixpanel::Tracker.new('fake-api-key')
    end
  end
end
