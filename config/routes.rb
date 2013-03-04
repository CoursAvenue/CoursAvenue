# encoding: utf-8
LeBonCours::Application.routes.draw do


  #ActiveAdmin.routes(self)

  # devise_for :admin_users, ActiveAdmin::Devise.config
  # devise_for :admin_users, path: 'profs', controllers: { sessions: "admins/sessions" }, path_names: { sign_in: '/', sign_out: 'logout'}#, :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }

  constraints :subdomain => 'pro' do
    scope :module => 'pro' do
      root :to => 'home#index'
      resources :structures do
        resources :places
        resources :courses
      end
      resources :admin_users
      devise_for :admin_users, controllers: { sessions: 'pro/admin/sessions', registrations: 'pro/admin/registrations', passwords: 'pro/admin/passwords'} , path: '/', path_names: { sign_in: '/connexion', sign_out: 'logout', registration: 'rejoindre-leboncours-pro', sign_up: '/'}#, :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
    end
  end


  match "sitemap.xml", to: "sitemap#index", defaults: {format: :xml}

  resources :newsletter_users, only: [:create]


  resources :courses, only: 'show', path: 'cours'
  resources :city, path: 'ville' do
    resources :subjects, only: [:show, :index], defaults: {city_id: 'paris'}, path: 'disciplines'
  end

  # Pages
  match 'pages/pourquoi-le-bon-cours'         => 'pages#why',               as: 'pages_why'
  match 'pages/comment-ca-marche'             => 'pages#how_it_works',      as: 'pages_how_it_works'
  match 'pages/faq-utilisateurs'              => 'pages#faq_users',         as: 'pages_faq_users'
  match 'pages/faq-partenaires'               => 'pages#faq_partners',      as: 'pages_faq_partners'
  match 'pages/qui-sommes-nous'               => 'pages#who_are_we',        as: 'pages_who_are_we'
  match 'pages/contact'                       => 'pages#contact'
  match 'pages/service-client'                => 'pages#customer_service',  as: 'pages_customer_service'
  match 'pages/presse'                        => 'pages#press',             as: 'pages_press'
  match 'pages/jobs'                          => 'pages#jobs'
  match 'pages/trouver-un-espace'             => 'pages#find_a_place',      as: 'pages_find_a_place'
  match 'pages/mentions-legales-partenaires'  => 'pages#mentions_partners', as: 'pages_mentions_partners'

  root :to => 'home#index'
end


