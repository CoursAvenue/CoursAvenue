require 'rails_helper'

describe Pro::ContactsController do
  include Devise::TestHelpers

  let(:structure) { FactoryGirl.create(:structure_with_admin) }
  let(:admin)     { structure.admin }

  before { sign_in admin }

  before do
    # We manually set our test data because omnicontacts test API can only be used for integration
    # tests.
    request.env['omnicontacts.contacts'] = [
      { id: Faker::Internet.password, emails: [ { email: Faker::Internet.email } ] },
      { id: Faker::Internet.password, emails: [ { email: Faker::Internet.email } ]},
      { id: Faker::Internet.password, emails: [ ]}
    ]
  end

  describe 'GET #callback' do
    it 'removes the contacts with empty emails' do
      get :callback, importer: 'gmail'
      expect(assigns(:contacts).length).to eq(2)
    end

    it 'renders with the empty body layout' do
      get :callback, importer: 'gmail'
      expect(response).to render_with_layout('empty_body')
    end
  end

  describe 'GET #failure' do
    it 'renders with the empty body layout' do
      get :failure
      expect(response).to render_with_layout('empty_body')
    end
  end
end
