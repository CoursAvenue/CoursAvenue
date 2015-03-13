require 'rails_helper'

describe MailerPreviewer do
  describe '.convert' do
    let(:content) { Faker::Lorem.paragraph }
    let(:mail)    { TestMailer.preview_test(content) }

    subject { MailerPreviewer.convert(mail) }

    it 'returns the content of the mailer' do
      expect(subject).to include(content)
    end
  end
end
