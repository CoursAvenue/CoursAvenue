require 'rails_helper'

describe UserMailer do
  describe 'welcome' do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.welcome(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Bienvenue sur CoursAvenue.com')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['contact@coursavenue.com'])
    end

    it 'renders the body' do
      expect(mail.html_part.body.encoded).to include(user.name)
    end
  end

  context :comment_notification do
    context 'after creation' do
      it 'sends an email after create' do
        comment_notification = FactoryGirl.build :comment_notification
        expect {
          comment_notification.save
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(comment_notification.status).to eq nil
      end
    end
  end
end
