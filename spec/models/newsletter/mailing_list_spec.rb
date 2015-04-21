require 'rails_helper'

RSpec.describe Newsletter::MailingList, type: :model do
  let(:newsletter) { FactoryGirl.create(:newsletter) }
  let(:structure)  { newsletter.structure }
  subject          { FactoryGirl.create(:newsletter_mailing_list, structure: structure) }

  describe '#create_recipients' do
    let(:tag) { Faker::Name.first_name }

    before do
      5.times do |i|
        profile = FactoryGirl.create(:user_profile, structure: structure)
        structure.tag(profile, with: tag, on: :tags) if i.even?
      end
      structure.save
    end

    context 'with all profiles' do
      before do
        subject.all_profiles = true
        subject.save
      end

      it 'creates the recipients using all of the newsletter profiles' do
        recipients = subject.create_recipients(newsletter)

        expect(recipients.count).to eq(5)
      end
    end

    context 'with a tag' do

      before do
        subject.tag = tag
        subject.save
      end

      it 'creates the recipients using the mailing list tag' do
        recipients = subject.create_recipients(newsletter)

        expect(recipients.count).to eq(3)
      end
    end
  end
end
