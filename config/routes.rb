LeBonCours::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "sitemap.xml", :to => "sitemap#index", :defaults => {:format => :xml}

  resources :newsletter_users, only: [:create]

  scope '/cours' do
    resources :city, path: 'ville' do
      resources :courses, only: 'show', path: 'cours'
      resources :subjects, only: [:show, :index], defaults: {city_id: 'paris'}, path: 'disciplines'
    end
  end

  root :to => 'home#index'
end


