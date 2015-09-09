require 'rails_helper'
require 'mandrill'

describe MandrillFactory do
  it { expect(Rails.env).to be_test }

  it 'returns a fake client in a non production env' do
    fake_client = FakeMandrill::Client

    expect(MandrillFactory.client).to be_a(fake_client)
  end

  it 'returns a real client in a production env' do
    real_client = Mandrill::API
    ENV['MANDRILL_API_KEY'] = Faker::Internet.password

    switch_to_prod_env do
      expect(MandrillFactory.client).to be_a(real_client)
    end
    ENV['MANDRILL_API_KEY'] = nil
  end

  def switch_to_prod_env
    Rails.env = 'production'
    yield
  ensure
    Rails.env = 'test'
  end
end
