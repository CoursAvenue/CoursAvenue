require 'spec_helper'

describe UserMailer do
  describe 'welcome' do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.welcome(user) }

    it 'renders the headers' do
      mail.subject.should eq('Bienvenue sur CoursAvenue.com')
      mail.to.should eq([user.email])
      mail.from.should eq(['contact@coursavenue.com'])
    end

    it 'renders the body' do
      mail.body.encoded.should match(user.name)
    end
  end

end
