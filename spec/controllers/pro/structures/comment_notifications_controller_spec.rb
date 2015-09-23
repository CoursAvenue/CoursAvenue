require 'rails_helper'

describe Pro::Structures::CommentNotificationsController do
  include ActionDispatch::TestProcess
  include Devise::TestHelpers

  describe 'POST #create' do
    it 'creates the comment notifications' do
      admin = FactoryGirl.create(:admin)
      structure = admin.structure
      email_count = 10

      sign_in admin
      valid_params = create_valid_params(email_count).merge(structure_id: structure.slug)

      expect { post :create, valid_params }.
        to change { CommentNotification.count }.by(email_count)
    end
  end

  def create_valid_params(email_count = 10)
    emails = email_count.times.map { Faker::Internet.email }.join(', ')

    {
      emails: emails,
      text: Faker::Lorem.paragraph
    }
  end
end
