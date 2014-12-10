require "rails_helper"

describe Pro::Structures::CommentNotificationsController do
  include Devise::TestHelpers
  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  describe "POST #create" do
    it 'creates a comment notification' do
      initial_length = admin.structure.comment_notifications.length
      post :create, structure_id: admin.structure.slug, emails: "person#{rand.to_s.gsub('.', '')}@example.com", text: 'lorem'
      expect(admin.structure.comment_notifications.length).to eq (initial_length + 1)
    end
  end
end
