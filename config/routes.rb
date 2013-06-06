# encoding: utf-8
CoursAvenue::Application.routes.draw do

  # ---------------------------------------------
  # ----------------------------------------- PRO
  # ---------------------------------------------
  constraints subdomain: 'pro' do
    namespace :pro, path: '' do
      root :to => 'home#index'
      match 'pages/presentation'           => 'home#presentation'
      match 'pages/offre-et-tarifs'        => 'home#price', as: 'pages_price'
      match 'pages/presse'                 => 'home#press', as: 'pages_press'
      match '/dashboard'                   => 'dashboard#index', as: 'dashboard'
      # Import contacts
      match "/contacts/:importer/callback" => "structures#import_mail_callback"
      match "/contacts/failure"            => "structures#import_mail_callback_failure"


      resources :comments, only: [:index], controller: 'comments'
      resources :subjects
      resources :reservation_loggers, only: [:index, :destroy]
      resources :structures, path: 'etablissements' do
        devise_for :admins, controllers: { registrations: 'pro/admins/registrations'}, path: '/', path_names: { registration: 'rejoindre-coursavenue-pro', sign_up: '/' }
        resources :comments, only: [:index], controller: 'structures/comments'
        member do
          put  'activate'
          put  'disable_condition'
          put  'validate_condition'
          get  'recommendations', path: 'recommandations'
          post 'get_feedbacks'
          get  'share_on_facebook', path: 'partager-sur-facebook'
        end
        collection do
          get 'select', path: 'referencer-mes-cours'
          get 'new_from_recomendation', path: 'demande-de-recommandations'
          post 'create_and_get_feedbacks'
          get 'import_mail_callback'
          get 'import_mail_callback_failure'
        end
        resources :teachers
        resources :places

        resources :courses, only: [:new, :create], path: 'cours' # To insure to have the structure_id
      end
      resources :courses, except: [:new, :create], path: 'cours' do
        member do
          post 'update' # For paperclip image
        end
        resources :plannings,  only: [:edit, :index, :destroy]
        resources :prices, only: [:index]
        resources :book_tickets, only: [:edit, :index, :destroy]
        member do
          put 'update_price'
          put 'activate'
          put 'disable'
        end
      end
      resources :course_workshops, controller: 'courses' do
        resources :plannings, only: [:create, :update]
      end
      resources :course_trainings, controller: 'courses' do
        resources :plannings, only: [:create, :update]
      end
      resources :course_lessons, controller: 'courses' do
        resources :plannings, only: [:create, :update]
      end

      resources :students, only: [:index]
      resources :users, only: [:index]

      resources :admins do
        collection do
          get 'activez-votre-compte' => 'admins#waiting_for_activation', as: 'waiting_for_activation'
        end
        member do
          put 'activate'
          put 'disable'
        end
      end
      devise_for :admins, controllers: { sessions: 'pro/admins/sessions', registrations: 'pro/admins/registrations', passwords: 'pro/admins/passwords', confirmations: 'pro/admins/confirmations'} , path: '/', path_names: { sign_in: '/connexion', sign_out: 'logout', registration: 'rejoindre-coursavenue-pro', sign_up: '/', :confirmation => 'verification'}#, :password => 'secret', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
    end
  end

  # ---------------------------------------------
  # ----------------------------------------- WWW
  # ---------------------------------------------
  devise_for :users, controllers: { :omniauth_callbacks => 'users/omniauth_callbacks', sessions: 'users/sessions', registrations: 'users/registrations' }
  resources  :users, only: [:show], path: 'eleves'

  match 'auth/:provider/callback', to: 'session#create'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'session#destroy', as: 'signout'


  resources :cities, only: [] do
    collection do
      get 'zip_code_search'
      get 'name_search'
    end
  end

  resources :reservations, only: [:create]

  resources :structures, only: [], path: 'etablissements' do
    resources :comments, only: [:new], path: 'recommandations', controller: 'structures/comments'
  end
  resources :students, only: [:create]

  resources :comments, only: [:create, :destroy]

  resources :places, only: [:show, :index], path: 'etablissements'
  resources :courses, only: [:show, :index], path: 'cours' do
    resources :reservations, only: [:new, :create] # Redirection 301 in controller
  end

  resources :subjects, only: [], path: 'disciplines' do
    resources :places, only: [:index], path: 'etablissements'
    resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index' # établissement without S
    resources :courses, only: [:index], path: 'cours'
  end

  resources :renting_rooms, only: [:create]

  resources :reservation_loggers, only: [:create]
  resources :click_loggers, only: [:create]

  # ---------------------------------------------------------
  # ----------------------------------------- Redirection 301
  # ---------------------------------------------------------
  # Catching all 301 redirection
  resources :subjects, only: [], path: 'disciplines' do
    resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index'
  end
  resources :places, only: [:show],  path: 'etablissement', to: 'redirect#place_show' # établissement without S
  resources :places, only: [:index], path: 'etablissement', to: 'redirect#place_index' # établissement without S
  match 'lieux',                                            to: 'redirect#lieux'
  match 'lieux/:id',                                        to: 'redirect#lieux_show'
  match 'ville/:city_id/disciplines/:subject_id',           to: 'redirect#city_subject'
  match 'ville/:city_id/cours/:subject_id',                 to: 'redirect#city_subject'
  match 'ville/:id',                                        to: 'redirect#city'
  match 'disciplines/:id',                                  to: 'redirect#disciplines'

  # ------------------------------------------------------
  # ----------------------------------------- Static pages
  # ------------------------------------------------------
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

  match '/blog'     => redirect('/blog/')
  # match '/wp-admin' => redirect('http://coursavenue-blog.herokuapp.com/wp-admin/')

  root :to => 'home#index'
end
