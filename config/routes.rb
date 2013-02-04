LeBonCours::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "sitemap.xml", :to => "sitemap#index", :defaults => {:format => :xml}

  resources :newsletter_users, only: [:create]


  # resources :city do
  #   resources :subject
  # end

  scope '/cours' do
    resources :city do
      resources :courses, only: 'show'
      resources :subjects, only: 'show'
    end
  end
  # resources :courses, only: [:index], controller: 'courses', type: Course.name, path: 'cours/:city/:subject', defaults: {city: 'paris', subject: I18n.t('all_subject_route_name')}
  resources :courses, only: [:show] , controller: 'courses', type: Course.name, path: ':type/:city/:subject', defaults: {city: 'paris', subject: I18n.t('all_subject_route_name')}

  root :to => 'home#index'
end


