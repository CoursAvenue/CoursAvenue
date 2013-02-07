LeBonCours::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "sitemap.xml", :to => "sitemap#index", :defaults => {:format => :xml}

  resources :newsletter_users, only: [:create]

  resources :city, path: 'ville' do
    resources :courses, only: 'show', path: 'cours'
    resources :subjects, only: [:show, :index], defaults: {city_id: 'paris'}, path: 'disciplines'
  end

  # Pages
  match 'pages/why'               => 'pages#why'
  match 'pages/comment-ca-marche' => 'pages#how_it_works',      as: 'pages_how_it_works'
  match 'pages/faq'               => 'pages#faq'
  match 'pages/mentions'          => 'pages#mentions'
  match 'pages/qui-sommes-nous'   => 'pages#who_are_we',        as: 'pages_who_are_we'
  match 'pages/contact'           => 'pages#contact'
  match 'pages/service-client'    => 'pages#customer_service',  as: 'pages_customer_service'
  match 'pages/presse'            => 'pages#press',             as: 'pages_press'
  match 'pages/jobs'              => 'pages#jobs'

  root :to => 'home#index'
end


