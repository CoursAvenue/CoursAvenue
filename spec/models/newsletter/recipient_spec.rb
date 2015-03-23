require 'rails_helper'

RSpec.describe Newsletter::Recipient, type: :model do
  describe 'defaults' do
    subject { FactoryGirl.create(:newsletter_recipient) }

    it 'is not opened' do
      expect(subject.opened?).to be_falsy
    end
  end

  describe '#email' do
    subject       { FactoryGirl.create(:newsletter_recipient) }
    let(:profile) { subject.user_profile }

    it "is equal to the profile's email" do
      expect(subject.email).to eq(profile.email)
    end
  end

  describe '#to_mandrill_recipient' do
    subject       { FactoryGirl.create(:newsletter_recipient) }
    let(:profile) { subject.user_profile }

    it 'create a new object with the right fields' do
      mandrill_recipient = subject.to_mandrill_recipient

      expect(mandrill_recipient[:email]).to eq(subject.email)
      expect(mandrill_recipient[:name]).to  eq(profile.name)
      expect(mandrill_recipient[:type]).to  eq('bcc')
    end

  end
end
