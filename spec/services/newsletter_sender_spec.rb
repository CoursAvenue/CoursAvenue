require 'rails_helper'

describe NewsletterSender do
  describe '.send_newsletter', with_mail: true do
    it "doesn't send the newsletter if there's no mailing list" do
      newsletter = FactoryGirl.create(:newsletter, :without_mailing_list)

      expect(NewsletterSender.send_newsletter(newsletter)).to be_falsy
    end

    it "doesn't send the newsletter if it has alredy been sent" do
      newsletter = FactoryGirl.create(:newsletter, :sent)

      expect(NewsletterSender.send_newsletter(newsletter)).to be_falsy
    end

    it 'sends the newsletter' do
      newsletter = FactoryGirl.create(:newsletter)

      mailing_list = newsletter.mailing_list
      mailing_list.structure = newsletter.structure
      mailing_list.save

      expect(NewsletterSender.send_newsletter(newsletter)).to be_truthy
    end

    it 'sets the newsletter as sent' do
      newsletter = FactoryGirl.create(:newsletter)

      mailing_list = newsletter.mailing_list
      mailing_list.structure = newsletter.structure
      mailing_list.save

      NewsletterSender.send_newsletter(newsletter)

      expect(newsletter.sent?).to be_truthy
    end
  end
end
