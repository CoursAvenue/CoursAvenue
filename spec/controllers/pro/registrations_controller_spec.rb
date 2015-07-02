require 'rails_helper'

describe Pro::RegistrationsController do
  describe 'GET #new' do
    it 'assigns a registration form'
  end

  describe 'POST #create' do
    context 'when the params are not valid' do
      it "doesn't create a new structure and a new admin"
      it 'renders the creation form'
    end

    context 'when the params are valid' do
      it "creates a new structure and a new admin"
      it 'redirects to the second part of the registration'
    end
  end
end
