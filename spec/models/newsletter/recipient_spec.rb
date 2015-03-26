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

  describe '#mandrill_recipient_metadata' do
    subject          { FactoryGirl.create(:newsletter_recipient) }
    let(:profile)    { subject.user_profile }
    let(:newsletter) { subject.newsletter }

    it 'creates a new object with the metadata' do
      recipient_metadata = subject.mandrill_recipient_metadata

      expect(recipient_metadata[:rcpt]).to                     eq(subject.email)
      expect(recipient_metadata[:values][0][:user_profile]).to eq(profile.id)
      expect(recipient_metadata[:values][0][:newsletter]).to   eq(newsletter.id)
    end
  end

  describe '#update_message_status' do
    # let(:mocked_infos) { {
    #   opens:  rand(1..30),
    #   clicks: rand(1..30),
    #   state:  FakeMandrill::MessagesClient::STATUSES.sample }
    # }
    #
    # before do
    #   allow(FakeMandrill::MessagesClient).to receive(:info).and_return(mocked_infos)
    # end
    #
    # it 'updates the different metric attributes' do
    #   subject.update_message_status
    #   subject.reload
    #
    #   expect(subject.opened).to be_truthy
    #   expect(subject.opens).to eq(mocked_infos[:opens])
    #   expect(subject.clicks).to eq(mocked_infos[:clicks])
    #   expect(subject.mandrill_message_status).to eq(mocked_infos[:state])
    # end
  end
end
