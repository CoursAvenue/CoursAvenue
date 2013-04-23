# encoding: utf-8
CoursAvenue::Application.routes.draw do

  constraints subdomain: 'pro' do
    namespace :pro, path: '' do
      root :to => 'home#index'
      match 'pages/presentation'    => 'home#presentation'
      match 'pages/offre-et-tarifs' => 'home#price', as: 'pages_price'
      match 'pages/presse'          => 'home#press', as: 'pages_press'
      match '/dashboard'            => 'dashboard#index', as: 'dashboard'

      resources :subjects
      resources :reservation_loggers, only: [:index, :destroy]
      resources :structures do
        member do
          put 'activate'
          put 'disable_condition'
          put 'validate_condition'
          get 'validation'
        end
        collection do
          get 'awaiting'
        end
        #resources :admins, only: [:create, :update], controller: 'structures/admins'
        resources :teachers
        resources :places

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
      devise_for :admins, controllers: { sessions: 'pro/admin/sessions', registrations: 'pro/admin/registrations', passwords: 'pro/admin/passwords'} , path: '/', path_names: { sign_in: '/connexion', sign_out: 'logout', registration: 'rejoindre-coursavenue-pro', sign_up: '/'}#, :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
    end
  end

  resources :cities, only: [:index]

  resources :newsletter_users, only: [:create]

  resources :comments, only: [:create]
  resources :courses, only: [:show, :index], path: 'cours' do
    resources :reservations, only: [:new, :create] # Redirection 301 in controller
  end

  resources :subjects, only: [], path: 'disciplines' do
    resources :places, only: [:index], path: 'etablissements'
    resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index'
    resources :courses, only: [:index], path: 'cours'
  end
  resources :places, only: [:show, :index], path: 'etablissements'

  resources :renting_rooms, only: [:create]

  resources :reservation_loggers, only: [:create]
  resources :click_loggers, only: [:create]

  # Catching all 301 redirection
  resources :subjects, only: [], path: 'disciplines' do
    resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index'
  end
  resources :places, only: [:show],  path: 'etablissement', to: 'redirect#place_show'
  resources :places, only: [:index], path: 'etablissement', to: 'redirect#place_index'
  match 'lieux',                                            to: 'redirect#lieux'
  match 'lieux/:id',                                        to: 'redirect#lieux_show'
  match 'ville/:city_id/disciplines/:subject_id',           to: 'redirect#city_subject'
  match 'ville/:id',                                        to: 'redirect#city'

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
  match 'pages/mentions-legales-partenaires'  => 'pages#mentions_partners',    as: 'pages_mentions_partners'
  match 'pages/conditions-generale-de-vente'  => 'pages#terms_and_conditions', as: 'pages_terms_and_conditions'

  root :to => 'home#index'
end


