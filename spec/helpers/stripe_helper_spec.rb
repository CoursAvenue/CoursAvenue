require 'rails_helper'

describe StripeHelper do
  describe '#stripe_dashboard_url' do
    it 'the stripe test URL when not in production' do
      expect(helper.stripe_dashboard_url).to match(/test/)
    end

    it 'returns the stripe production URL when in production' do
      switch_to_prod_env do
        expect(helper.stripe_dashboard_url).to_not match(/test/)
      end
    end
  end

  def switch_to_prod_env
    Rails.env = 'production'
    yield
  ensure
    Rails.env = 'test'
  end
end
