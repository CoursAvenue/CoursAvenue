require 'rails_helper'

describe NexmoClientFactory, '' do
  it { expect(Rails.env).to be_test }

  it 'returns a fake client in non production env' do
    fake_client = FakeNexmo::Client

    expect(NexmoClientFactory.client).to be_a(fake_client)
  end

  it 'returns a real client in production env' do
    real_client = Nexmo::Client

    switch_to_prod_env do
      expect(NexmoClientFactory.client(key: '', secret: '')).to be_a(real_client)
    end
  end

  def switch_to_prod_env
    Rails.env = 'production'
    yield
  ensure
    Rails.env = 'test'
  end
end
