require 'rails_helper'

RSpec.describe Newsletter, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :state }
  # it { should belong_to(:structure) }
  # it { should have_many(:blocs) }

  subject          { FactoryGirl.create(:newsletter) }
  let!(:structure) { subject.structure }

  describe 'defaults' do
    it 'is a draft by default' do
      expect(subject.state).to eq('draft')
    end

    it 'sets the default sender name' do
      expect(subject.sender_name).to eq(structure.name)
    end

    it 'sets the default reply to address' do
      expect(subject.reply_to).to eq(structure.contact_email)
    end

    it 'sets the default email object' do
      expect(subject.email_object).to eq(subject.title)
    end
  end

  describe '#layout' do
    it 'returns the layout used by the newsletter' do
      expect(subject.layout).to eq(Newsletter::Layout.find(subject.layout_id))
    end
  end

  describe '#sent?' do
    context 'the newsletter was not sent' do
      it 'returns false' do
        expect(subject.sent?).to be_falsy
      end
    end

    context 'the newsletter was sent' do
      subject { FactoryGirl.create(:newsletter, :sent) }
      it 'returns true' do
        expect(subject.sent?).to be_truthy
      end
    end
  end

  describe 'draft?' do
    context 'the newsletter was not sent' do
      it 'returns false' do
        expect(subject.draft?).to be_truthy
      end
    end

    context 'the newsletter was sent' do
      subject { FactoryGirl.create(:newsletter, :sent) }
      it 'returns true' do
        expect(subject.draft?).to be_falsy
      end
    end
  end

  describe '#duplicate!' do
    it 'duplicates all of the attributes of the newsletter except the state' do
      duplicated_newsletter = subject.duplicate!

      expect(duplicated_newsletter.title).to        eq(subject.title)
      expect(duplicated_newsletter.email_object).to eq(subject.email_object)
      expect(duplicated_newsletter.sender_name).to  eq(subject.sender_name)
      expect(duplicated_newsletter.reply_to).to     eq(subject.reply_to)
      expect(duplicated_newsletter.layout_id).to    eq(subject.layout_id)
    end

    it 'makes the duplicated newsletter a draft' do
      duplicated_newsletter = subject.duplicate!

      expect(duplicated_newsletter.state).to eq('draft')
    end
  end

  describe 'send!' do
    it 'updates the state' do
      subject.send!

      expect(subject.state).to eq('sent')
    end

    it 'updates the send_at date' do
      subject.send!

      expect(subject.sent_at).to_not be_nil
    end
  end

  describe '#to_mandrill_message' do
    it 'sets the right values' do
      mandrill_message = subject.to_mandrill_message
      body = MailerPreviewer.preview(NewsletterMailer.send_newsletter(subject, nil))

      expect(mandrill_message[:html]).to       eq(body)
      expect(mandrill_message[:subject]).to    eq(subject.email_object)
      expect(mandrill_message[:from_email]).to eq(Newsletter::NEWSLETTER_FROM_EMAIL)
      expect(mandrill_message[:from_name]).to  eq(subject.sender_name)
    end
  end
end
