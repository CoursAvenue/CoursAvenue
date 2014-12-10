# -*- encoding : utf-8 -*-
require 'rails_helper'

describe PlacesController do

  subject {place}
  let(:place) { FactoryGirl.create(:place) }

  describe '#show' do
    before do
      Rails.application.config.consider_all_requests_local = false
      load "application_controller.rb"
    end

    after do
      Rails.application.config.consider_all_requests_local = true
      load "application_controller.rb"
    end

    context 'when resource is found' do
      it { expect(response).to have_http_status(:success) }
    end
  end

  describe '#index' do
  end
end
