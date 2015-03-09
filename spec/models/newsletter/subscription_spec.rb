require 'rails_helper'

RSpec.describe Newsletter::Subscription, :type => :model do
  describe 'default' do
    subject { FactoryGirl.create(:newsletter_subscription) }

    it 'is subscribed by default' do
      expect(subject.subscribed?).to be_truthy
    end
  end
end
