class MixpanelClientFactory
  def self.client
    if Rails.env.test?
      FakeMixpanel::Tracker.new('fake-api-key')
    else
      Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_TOKEN'])
    end
  end
end
