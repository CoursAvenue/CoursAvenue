# encoding: utf-8
CoursAvenue::Application.routes.draw do

  # ---------------------------------------------
  # ----------------------------------------- PRO
  # ---------------------------------------------
  constraints subdomain: 'pro' do
    namespace :pro, path: '' do
      root :to => 'home#index'
      match 'pages/pourquoi-etre-recommande'      => 'home#why_be_recommended', as: 'pages_why_be_recommended'
      match 'pages/presentation'                  => 'home#presentation'
      match 'pages/questions-les-plus-frequentes' => 'home#questions',          as: 'pages_questions'
      match 'pages/offre-et-tarifs'               => 'home#price',              as: 'pages_price'
      match 'pages/nos-convictions'               => 'home#convictions',        as: 'pages_convictions'
      match 'pages/presse'                        => 'home#press',              as: 'pages_press'
      match '/dashboard'                          => 'dashboard#index',         as: 'dashboard'
      # 301 Redirection
      match 'etablissements/demande-de-recommandations', to: 'redirect#structures_new'
      match 'inscription'                              , to: 'structures#new'
      match 'sms'                                      , to: 'structures#new'

      match 'tableau-de-bord'                          , to: 'redirect#structure_dashboard'


      resources :comments, only: [:edit, :update, :index, :destroy] do
        member do
          put :recover
        end
      end
      resources :subjects
      resources :reservation_loggers, only: [:index, :destroy]
      resources :invited_teachers, only: [:index]
      resources :structures, path: 'etablissements' do
        member do
          get  :update_widget_status
          get  :wizard
          get  :flyer
          get  :signature
          get  :dashboard, path: 'tableau-de-bord'
          put  :activate
          put  :disable
          get  :recommendations, path: 'recommandations'
          get  :coursavenue_recommendations, path: 'recommander-coursavenue'
          post :get_feedbacks
          post :recommend_friends
          post :update
          get  :sticker
          get  :widget
          match 'widget_ext', controller: 'structures', action: 'widget_ext', constraints: {methods: ['OPTIONS', 'GET']}, as: 'widget_ext'
        end
        collection do
          get :stars
          get 'inscription', to: :new
        end
        devise_for :admins, controllers: { registrations: 'pro/admins/registrations'}, path: '/', path_names: { registration: 'rejoindre-coursavenue-pro', sign_up: '/' }
        devise_scope :admins do
          collection do
            get 'unsubscribe/:signature' => 'admins#unsubscribe', as: 'unsubscribe'
          end
        end
        resources :invited_teachers, only: [:index], controller: 'structures/invited_teachers'
        resources :comments, only: [:index], controller: 'structures/comments' do
          member do
            put :accept
            put :decline
            put :ask_for_deletion
          end
        end
        resources :medias, controller: 'structures/medias'
        resources :teachers
        resources :places
        resources :students, only: [:index, :destroy], controller: 'structures/students'

        resources :courses, only: [:index, :new, :create], path: 'cours'#, controller: 'structures/courses' # To insure to have the structure_id
      end
      resources :courses, except: [:new, :create], path: 'cours' do
        member do
          post 'update' # For paperclip image
          post 'duplicate'
          post 'copy_prices_from'
        end
        resources :plannings,  only: [:new, :edit, :index, :destroy] do
          member do
            post 'duplicate'
          end
        end
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

      resources :students, only: [:index] do
        member do
          post 'ask_for_feedbacks_stage_1'
        end
      end
      resources :users, only: [:index]

      resources :admins do
        collection do
          get 'activez-votre-compte' => 'admins#waiting_for_activation', as: 'waiting_for_activation'
        end
        member do
          put 'confirm'
        end
      end
      devise_for :admins, controllers: { sessions: 'pro/admins/sessions', registrations: 'pro/admins/registrations', passwords: 'pro/admins/passwords', confirmations: 'pro/admins/confirmations'} , path: '/', path_names: { sign_in: '/connexion', sign_out: 'logout', registration: 'rejoindre-coursavenue-pro', sign_up: '/', :confirmation => 'verification'}#, :password => 'secret', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
    end
  end

  # ---------------------------------------------
  # ----------------------------------------- WWW
  # ---------------------------------------------
  devise_for :users, controllers: { :omniauth_callbacks => 'users/omniauth_callbacks', sessions: 'users/sessions', registrations: 'users/registrations' }
  resources  :users, only: [:edit, :show, :update], path: 'eleves' do
    resources  :comments, only: [:index, :edit, :update], controller: 'users/comments'
  end
  resources :emails, only: [:create]

  match 'auth/:provider/callback', to: 'session#create'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'session#destroy', as: 'signout'


  resources :cities, only: [] do
    collection do
      get 'zip_code_search'
      get 'name_search'
    end
  end

  resources :locations, only: [:index]
  resources :subjects, only: [:index] do
    collection do
      get :tree
      get :tree_2
      get :descendants
    end
  end

  resources :reservations, only: [:create]

  resources :students, only: [:create] do
    collection do
      get 'unsubscribe/:signature' => 'students#unsubscribe', as: 'unsubscribe'
    end
  end

  resources :comments, only: [:create]

  resources :structures, only: [:show, :index], path: 'etablissements', controller: 'structures' do
    collection do
      post :recommendation
    end
    resources :courses , only: [:show], path: 'cours', controller: 'structures/courses'
    resources :comments, only: [:new, :show], path: 'recommandations', controller: 'structures/comments'
  end

  resources :courses, only: [:show, :index], path: 'cours' do
    resources :reservations, only: [:new, :create] # Redirection 301 in controller
  end

  resources :subjects, only: [], path: 'disciplines' do
    resources :structures, only: [:index], path: 'etablissements'
    # resources :places, only: [:index], path: 'etablissements'
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
  resources :places, only: [:show],  path: 'etablissement',            to: 'redirect#place_show' # établissement without S
  resources :places, only: [:index], path: 'etablissement',            to: 'redirect#place_index' # établissement without S
  match 'lieux',                                                       to: 'redirect#lieux'
  match 'lieux/:id',                                                   to: 'redirect#lieux_show'
  match 'ville/:city_id/disciplines/:subject_id',                      to: 'redirect#city_subject'
  match 'ville/:city_id/cours/:subject_id',                            to: 'redirect#city_subject'
  match 'ville/:id',                                                   to: 'redirect#city'
  match 'disciplines/:id',                                             to: 'redirect#disciplines'

  # ------------------------------------------------------
  # ----------------------------------------- Static pages
  # ------------------------------------------------------
  # Pages
  match 'pages/pourquoi-le-bon-cours',        to: 'redirect#why_coursavenue'
  match 'pages/pourquoi-coursavenue'          => 'pages#why',                  as: 'pages_why'
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

  match '/musique', to: 'structures#index', subject_id: 'musique-chant'
  match '/danse', to: 'structures#index'  , subject_id: 'danse'
  match '/theatre', to: 'structures#index', subject_id: 'theatre'

  match '/blog' => redirect('/blog/')

  match 'contact/' => 'home#contact', via: [:post]

  root :to => 'home#index'
end
