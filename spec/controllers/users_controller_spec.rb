# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersController do

  describe :invite_entourage_to_jpo_page do
    it 'returns 200' do
      get :invite_entourage_to_jpo_page
      expect(response.status).to eq(200)
    end
  end

end
