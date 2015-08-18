# -*- encoding : utf-8 -*-
require 'rails_helper'

describe "301 Redirections" do

  let (:city)      { FactoryGirl.create(:city) }
  let (:subject)   { FactoryGirl.create(:subject) }
  let (:subject_2) { FactoryGirl.create(:subject) }

  # GET 'cours-de-:id-a/:city_id--:old_slug', to: 'redirect#structures_index'
  describe '/cours-de-clarinette-a/cergy--2' do
    it 'returns 301' do
      get "cours-de-#{subject.slug}-a/#{city.slug}--2"
      expect(response).to be_redirect
    end
  end

  # GET ':root_subject_id/:subject_id--:city_id--:old_city_slug', to: 'redirect#structures_index'
  describe '/musique-et-chant/clarinette--cergy--2' do
    it 'returns 301' do
      get "#{subject.slug}/#{subject_2.slug}--#{city.slug}--2"
      expect(response).to be_redirect
    end
  end

  # GET ':root_subject_id--:city_id--:old_city_slug', to: 'redirect#structures_index'
  describe '/musique-et-chant--cergy--2' do
    it 'returns 301' do
      get "#{subject.slug}--#{city.slug}--2"
      expect(response).to be_redirect
    end
  end
end
