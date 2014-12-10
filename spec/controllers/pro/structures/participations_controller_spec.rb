# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Pro::Structures::ParticipationsController do

  let(:admin) { FactoryGirl.create(:admin) }

  before do
    sign_in admin
  end

  describe 'index' do
    it 'returns 200' do
      get :index, structure_id: admin.structure.slug
      expect(response).to be_success
    end
  end

end
