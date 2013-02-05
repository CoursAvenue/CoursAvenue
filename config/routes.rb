LeBonCours::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "sitemap.xml", :to => "sitemap#index", :defaults => {:format => :xml}

  resources :newsletter_users, only: [:create]

  scope '/cours' do
    resources :city do
      resources :courses, only: 'show'
      resources :subjects, only: [:show, :index], defaults: {city_id: 'paris'}
    end
  end

  root :to => 'home#index'
end


