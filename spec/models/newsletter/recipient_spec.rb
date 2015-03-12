require 'rails_helper'

RSpec.describe Newsletter::Recipient, type: :model do
  describe 'defaults' do
    subject { FactoryGirl.create(:newsletter_recipient) }

    it 'is not opened' do
      expect(subject.opened?).to be_falsy
    end
  end
end
