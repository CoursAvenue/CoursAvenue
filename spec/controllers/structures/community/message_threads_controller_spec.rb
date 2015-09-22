require 'rails_helper'

describe Structures::Community::MessageThreadsController, community: true do
  include Devise::TestHelpers

  let(:structure)  { FactoryGirl.create(:structure) }
  let!(:community) { structure.community }
  let(:user)       { FactoryGirl.create(:user) }

  before do
    5.times { t = community.ask_question!(user, Faker::Lorem.paragraph); t.approve! }
  end

  describe 'GET #index' do
    context 'with json format' do
      it 'renders the community message threads' do
        get :index, structure_id: structure.slug, format: :json
        thread_ids = response_body.map { |t| t['id'] }
        expect(thread_ids).to match_array(community.message_threads.approved.map(&:id))
      end
    end

    context 'with html format' do
      it 'redirects to the structure page' do
        get :index, structure_id: structure.slug
        expect(response).to redirect_to(structure_path(structure))
      end
    end
  end

  describe 'POST #create' do
    let(:user)    { FactoryGirl.create(:user) }
    let(:message) { Faker::Lorem.paragraph(5) }

    before { sign_in user }

    it 'creates a new message thread' do
      expect { post :create, valid_params(structure, user) }.
        to change { Community::MessageThread.count }.by(1)
    end
  end

  describe 'PATCH #update' do
    let(:user)    { FactoryGirl.create(:user) }
    let(:message) { Faker::Lorem.paragraph(5) }
    let(:thread)  { community.ask_question!(user, message) }

    before { sign_in user }

    it 'adds a message to the thread' do
      expect { patch :update, valid_update_params(structure, user, thread) }.
        to change { thread.messages.count }.by(1)
    end
  end

  def response_body
    JSON.parse(response.body)
  end

  def valid_params(structure, user)
    {
      structure_id: structure.slug,
      community_message_thread: {
        user: {
          id: user.id,
        },
        message: Faker::Lorem.paragraph
      }
    }
  end

  def valid_update_params(structure, user, thread)
    {
      id: thread.id,
      structure_id: structure.slug,
      community_message_thread: {
        user: {
          id: user.id,
        },
        message: Faker::Lorem.paragraph
      }
    }
  end
end
