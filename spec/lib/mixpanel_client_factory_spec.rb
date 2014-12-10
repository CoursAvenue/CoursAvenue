require 'rails_helper'

describe MixpanelClientFactory, '' do

  it { expect(Rails.env).to be_test }

  it 'returns a Fake client in test mode' do
    fake_client = FakeMixpanel::Tracker

    expect(MixpanelClientFactory.client).to be_a(fake_client)
  end

  it 'returns a real client when in non-test mode' do
    real_client = Mixpanel::Tracker

    switch_to_non_test_mode do
      expect(MixpanelClientFactory.client).to be_a(real_client)
    end
  end

  def switch_to_non_test_mode
    Rails.env = 'non-test'
    yield
  ensure
    Rails.env = 'test'
  end

end
