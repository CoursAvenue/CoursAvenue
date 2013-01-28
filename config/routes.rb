LeBonCours::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "sitemap.xml", :to => "sitemap#index", :defaults => {:format => :xml}

  resources :newsletter_users, only: [:create]

  resources :courses, only: [:index], controller: 'courses', type: Course.name, path: 'cours/:city/:discipline', defaults: {city: 'paris', discipline: I18n.t('all_discipline_route_name')}
  resources :courses, only: [:show] , controller: 'courses', type: Course.name, path: ':type/:city/:discipline', defaults: {city: 'paris', discipline: I18n.t('all_discipline_route_name')}

  root :to => 'home#index'

end
