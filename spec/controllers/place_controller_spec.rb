# -*- encoding : utf-8 -*-
require 'spec_helper'

describe PlacesController do

  subject {place}
  let(:place) { FactoryGirl.create(:place) }

  # context 'slug cannot changes' do
  #   it 'keep the same slug' do
  #     initial_slug = place.slug
  #     place.name += ' some extension apzdoja dpaojz'
  #     place.save
  #     get :show, id: place.slug
  #     response.status.should eq 301
  #   end
  # end

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

    context 'when resource is not found' do
      it 'redirects to home page' do
        get :show, id: 'something_impossible'
        response.status.should eq 301
        response.should redirect_to root_path
      end
    end
  end

  describe '#index' do
  end
end
