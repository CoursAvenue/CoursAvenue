require 'spec_helper'

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

end
