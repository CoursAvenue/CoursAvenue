require 'spec_helper'

describe UserMailer do
  describe 'welcome' do
    let(:user) { FactoryGirl.build(:user) }
    let(:mail) { UserMailer.welcome(user) }

    it 'renders the headers' do
      mail.subject.should eq('Bienvenue sur CoursAvenue.com')
      mail.to.should eq([user.email])
      mail.from.should eq(['contact@coursavenue.com'])
    end

    it 'renders the body' do
      mail.body.encoded.should match(user.first_name)
    end
  end

end
