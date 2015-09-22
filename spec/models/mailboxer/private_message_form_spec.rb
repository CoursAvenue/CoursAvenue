require 'rails_helper'

describe Mailboxer::PrivateMessageForm do
  describe '#save' do
    context 'when the structure is invalid' do
      it "doesn't persist the message" do
        message = Mailboxer::PrivateMessageForm.new({
          message: Faker::Lorem.paragraph, structure_id: Faker::Name.name.parameterize,
          user_id: Faker::Name.name.parameterize
        })

        expect(message.save).to be_falsy
      end
    end

    context 'when the user is invalid' do
      it "doesn't persist the message" do
        structure = FactoryGirl.create(:structure)
        message = Mailboxer::PrivateMessageForm.new({
          message: Faker::Lorem.paragraph, structure_id: structure.slug,
          user_id: Faker::Name.name.parameterize
        })

        expect(message.save).to be_falsy
      end
    end

    context "when the structure doesn't have an admin" do
      it "doesn't persist the message" do
        structure = FactoryGirl.create(:structure)
        user = FactoryGirl.create(:user)
        message = Mailboxer::PrivateMessageForm.new({
          message: Faker::Lorem.paragraph, structure_id: structure.slug,
          user_id: user.slug
        })
        structure.admin = nil

        expect(message.save).to be_falsy
      end
    end

    it 'sends a message' do
      structure = FactoryGirl.create(:structure_with_admin)
      user = FactoryGirl.create(:user)
      message = Mailboxer::PrivateMessageForm.new({
        message: Faker::Lorem.paragraph, structure_id: structure.slug,
        user_id: user.slug
      })

      expect { message.save }.to change { Mailboxer::Message.count }.by(1)
    end
  end
end
