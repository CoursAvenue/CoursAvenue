require 'rails_helper'

describe MailerPreviewer do
  describe '.preview', with_mail: true do
    let(:content) { Faker::Lorem.paragraph }
    let(:mail)    { TestMailer.preview_test(content) }

    subject { MailerPreviewer.preview(mail) }

    it 'returns the content of the mailer' do
      expect(subject).to include(content)
    end
  end
end
