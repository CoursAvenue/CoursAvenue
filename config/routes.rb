# encoding: utf-8
CoursMania::Application.routes.draw do
  resources :cities, only: [:index]

  resources :newsletter_users, only: [:create]

  resources :courses, only: 'show', path: 'cours'
  resources :city, path: 'ville' do
    resources :subjects, only: [:show, :index], defaults: {city_id: 'paris'}, path: 'disciplines'
  end

  resources :reservation_loggers, only: [:create]

  constraints :subdomain => 'pro' do
    scope :module => 'pro' do
      root :to => 'home#index'
      match 'pages/presentation'    => 'home#presentation'
      match 'pages/offre-et-tarifs' => 'home#price', as: 'pages_price'
      match 'pages/presse'          => 'home#press', as: 'pages_press'

      resources :reservation_loggers, only: [:index, :destroy]
      resources :structures do
        member do
          put 'activate'
          put 'disable_condition'
          put 'validate_condition'
        end
        collection do
          get 'awaiting'
        end
        #resources :admins, only: [:create, :update], controller: 'structures/admins'
        resources :teachers
        resources :places do
          resources :rooms, only: [:index, :create, :destroy]
        end
        resources :courses, only: [:new, :create], path: 'cours'
        resources :course_workshops, only: [:create, :update], controller: 'courses'
        resources :course_trainings, only: [:create, :update], controller: 'courses'
        resources :course_lessons, only: [:create, :update], controller: 'courses'
      end
      resources :courses, path: 'cours' do
        resources :plannings, only: [:edit, :index, :destroy]
        resources :prices, only: [:edit, :index, :destroy]
        resources :book_tickets, only: [:edit, :index, :destroy]
      end
      resources :course_workshops, controller: 'courses' do
        resources :plannings, only: [:create, :update]
        resources :prices, only: [:create, :update]
        resources :book_tickets, only: [:create, :update]
      end
      resources :course_trainings, controller: 'courses' do
        resources :plannings, only: [:create, :update]
        resources :prices, only: [:create, :update]
        resources :book_tickets, only: [:create, :update]
      end
      resources :course_lessons, controller: 'courses' do
        resources :plannings, only: [:create, :update]
        resources :prices, only: [:create, :update]
        resources :book_tickets, only: [:create, :update]
      end
      resources :admins
      devise_for :admins, controllers: { sessions: 'pro/admin/sessions', registrations: 'pro/admin/registrations', passwords: 'pro/admin/passwords'} , path: '/', path_names: { sign_in: '/connexion', sign_out: 'logout', registration: 'rejoindre-leboncours-pro', sign_up: '/'}#, :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
    end
  end

  # Pages
  match 'pages/pourquoi-le-bon-cours'         => 'pages#why',                  as: 'pages_why'
  match 'pages/comment-ca-marche'             => 'pages#how_it_works',         as: 'pages_how_it_works'
  match 'pages/faq-utilisateurs'              => 'pages#faq_users',            as: 'pages_faq_users'
  match 'pages/faq-partenaires'               => 'pages#faq_partners',         as: 'pages_faq_partners'
  match 'pages/qui-sommes-nous'               => 'pages#who_are_we',           as: 'pages_who_are_we'
  match 'pages/contact'                       => 'pages#contact'
  match 'pages/service-client'                => 'pages#customer_service',     as: 'pages_customer_service'
  match 'pages/presse'                        => 'pages#press',                as: 'pages_press'
  match 'pages/jobs'                          => 'pages#jobs'
  match 'pages/trouver-un-espace'             => 'pages#find_a_place',         as: 'pages_find_a_place'
  match 'pages/mentions-legales-partenaires'  => 'pages#mentions_partners',    as: 'pages_mentions_partners'
  match 'pages/conditions-generale-de-vente'  => 'pages#terms_and_conditions', as: 'pages_terms_and_conditions'

  root :to => 'home#index'
end


