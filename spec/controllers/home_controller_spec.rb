# -*- encoding : utf-8 -*-
require 'spec_helper'

describe HomeController do
  describe 'index' do
    it 'returns 200' do
      get :index
      expect(response.status).to eq(200)
    end
  end
end
