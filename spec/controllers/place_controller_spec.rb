# -*- encoding : utf-8 -*-
require 'spec_helper'

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
      it { response.status.should eq 200 }
    end
  end

  describe '#index' do
  end
end
