require 'rails_helper'

describe MixpanelClientFactory, '' do

  it { expect(Rails.env).to be_test }

  it 'returns a Fake client in non production env' do
    fake_client = FakeMixpanel::Tracker

    expect(MixpanelClientFactory.client).to be_a(fake_client)
  end

  it 'returns a real client when in production env' do
    real_client = Mixpanel::Tracker

    switch_to_prod_env do
      expect(MixpanelClientFactory.client).to be_a(real_client)
    end
  end

  def switch_to_prod_env
    Rails.env = 'production'
    yield
  ensure
    Rails.env = 'test'
  end

end
