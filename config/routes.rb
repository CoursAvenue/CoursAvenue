# encoding: utf-8
CoursAvenue::Application.routes.draw do

  # ---------------------------------------------
  # ----------------------------------------- PRO
  # ---------------------------------------------
  constraints subdomain: (Rails.env.staging? ? 'pro.staging' : 'pro') do
    namespace :pro, path: '' do
      root :to => 'home#index'
      get 'pages/pourquoi-etre-recommande'      => 'home#why_be_recommended', as: 'pages_why_be_recommended'
      get 'pages/presentation'                  => 'home#presentation'
      get 'pages/questions-les-plus-frequentes' => 'home#questions',          as: 'pages_questions'
      get 'pages/offre-et-tarifs'               => 'home#price',              as: 'pages_price'
      get 'pages/nos-convictions'               => 'home#convictions',        as: 'pages_convictions'
      get 'pages/presse'                        => 'home#press',              as: 'pages_press'
      get '/dashboard'                          => 'dashboard#index',         as: 'dashboard'
      # 301 Redirection
      get 'etablissements/demande-de-recommandations', to: 'redirect#structures_new'
      get 'inscription'                              , to: 'structures#new'
      get 'sms'                                      , to: 'structures#new'

      get 'tableau-de-bord'                          , to: 'redirect#structure_dashboard', as: 'structure_dashboard_redirect'
      get 'modifier-mon-profil'                      , to: 'redirect#structure_edit',      as: 'structure_edit_redirect'

      resources :click_logs, only: [:index]

      resources :comments, only: [:edit, :update, :index, :destroy] do
        member do
          patch :recover
        end
      end
      resources :keywords, only: [:index, :create, :destroy]
      resources :search_term_logs, only: [:index]
      resources :subjects
      resources :reservations, only: [:index]
      resources :invited_teachers, only: [:index]
      resources :sticker_demands, only: [:index]
      resources :structures, path: 'etablissements' do
        member do
          get   :update_widget_status
          get   :crop_logo
          get   :wizard
          get   :signature
          get   :dashboard, path: 'tableau-de-bord'
          patch :activate
          patch :disable
          get   :recommendations, path: 'recommandations'
          get   :coursavenue_recommendations, path: 'recommander-coursavenue'
          post  :recommend_friends
          post  :update
          get   :widget
          match :widget_ext, controller: 'structures', via: [:options, :get], as: 'widget_ext'
        end
        collection do
          get :stars
          get :best
          get :inscription, to: :new
        end
        devise_for :admins, controllers: { registrations: 'pro/admins/registrations'}, path: '/', path_names: { registration: 'rejoindre-coursavenue-pro', sign_up: '/' }
        devise_scope :admins do
          collection do
            get 'unsubscribe/:signature' => 'admins#unsubscribe', as: 'unsubscribe'
          end
        end
        resources :sticker_demands, only: [:create, :new, :index], controller: 'structures/sticker_demands' do
          member do
            put :update_sent
          end
        end

        resources :user_profiles, controller: 'structures/user_profiles', path: 'mes-eleves'
        resources :user_profile_imports, only: [:new, :create], controller: 'structures/user_profile_imports', path: 'importer-mes-eleves' do
          member do
            get   :choose_headers
            patch :import
          end
        end
        resources :invited_teachers, only: [:index], controller: 'structures/invited_teachers'
        resources :comment_notifications, controller: 'structures/comment_notifications'
        resources :comments, only: [:index], controller: 'structures/comments' do
          member do
            patch :accept
            patch :decline
            patch :ask_for_deletion
          end
        end
        resources :medias, only: [:index, :destroy], controller: 'structures/medias'
        resources :videos, only: [:create, :new], controller: 'structures/medias/videos'
        resources :images, only: [:create, :new], controller: 'structures/medias/images' do
          member do
            put :make_it_cover
          end
        end

        resources :teachers
        resources :places       , controller: 'structures/places'

        resources :messages     , controller: 'structures/messages'
        resources :conversations, controller: 'structures/conversations'
        resources :courses, only: [:index, :new, :create], path: 'cours'#, controller: 'structures/courses' # To insure to have the structure_id
      end
      resources :courses, except: [:new, :create], path: 'cours' do
        member do
          post 'update' # For paperclip image
          patch 'update' # For paperclip image
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
          patch 'update_price'
          patch 'activate'
          patch 'disable'
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

      resources :users                , only: [:index]
      resources :comment_notifications, only: [:index]
      resources :conversations        , only: [:index]

      resources :admins do
        collection do
          get 'activez-votre-compte' => 'admins#waiting_for_activation', as: 'waiting_for_activation'
        end
        member do
          patch 'confirm'
        end
      end
      devise_for :admins, controllers: { sessions: 'pro/admins/sessions', registrations: 'pro/admins/registrations', passwords: 'pro/admins/passwords', confirmations: 'pro/admins/confirmations'}, path: '/', path_names: { sign_in: '/connexion', sign_out: 'logout', registration: 'rejoindre-coursavenue-pro', sign_up: '/', :confirmation => 'verification'}#, :password => 'secret', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }
    end
  end

  # ---------------------------------------------
  # ----------------------------------------- WWW
  # ---------------------------------------------
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions', registrations: 'users/registrations'}
  resources  :users, only: [:edit, :show, :update], path: 'eleves' do
    collection do
      get 'unsubscribe/:signature' => 'users#unsubscribe', as: 'unsubscribe'
    end
    member do
      get :choose_password
      patch :first_update
    end
    resources :comments, only: [:index, :edit, :update], controller: 'users/comments'
    resources :messages     , controller: 'users/messages'
    resources :conversations, controller: 'users/conversations'
  end
  resources :emails, only: [:create]

  get 'auth/:provider/callback', to: 'session#create'
  get 'auth/failure'           , to: redirect('/')
  get 'signout'                , to: 'session#destroy', as: 'signout'


  resources :cities, only: [] do
    collection do
      get 'zip_code_search'
      get 'name_search'
    end
  end

  resources :locations, only: [:index]

  resources :reservations, only: [:create]

  resources :comments, only: [:create]

  resources :structures, only: [:show, :index], path: 'etablissements', controller: 'structures' do
    collection do
      post :recommendation
    end
    resources :messages , only: [:create], controller: 'structures/messages'
    resources :courses , only: [:show, :index], path: 'cours', controller: 'structures/courses'
    resources :comments, only: [:new, :show, :index], path: 'recommandations', controller: 'structures/comments'
    resources :medias, only: [:index], controller: 'structures/medias'
  end

  resources :courses, only: [:show, :index], path: 'cours' do
    resources :reservations, only: [:new, :create] # Redirection 301 in controller
  end

  resources :keywords, only: [:index]
  resources :subjects, only: [:index], path: 'disciplines' do
    resources :cities, only: [:show], path: 'villes', controller: 'subjects/cities' do
      resources :medias, only: [], controller: 'subjects/cities/medias' do
        collection do
          get :videos
        end
      end
    end
    collection do
      get :tree
      get :tree_2
      get :descendants
    end
    resources :structures, only: [:index], path: 'etablissements'
    # resources :places, only: [:index], path: 'etablissements'
    resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index' # établissement without S
    resources :courses, only: [:index], path: 'cours'
  end

  resources :reservation_loggers, only: [:create]
  resources :click_logs, only: [:create]

  # ---------------------------------------------------------
  # ----------------------------------------- Redirection 301
  # ---------------------------------------------------------
  # Catching all 301 redirection
  resources :subjects, only: [], path: 'disciplines' do
    resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index'
  end
  resources :places, only: [:show],  path: 'etablissement',            to: 'redirect#place_show' # établissement without S
  resources :places, only: [:index], path: 'etablissement',            to: 'redirect#place_index' # établissement without S
  get 'lieux',                                                       to: 'redirect#lieux'
  get 'lieux/:id',                                                   to: 'redirect#lieux_show'
  get 'ville/:city_id/disciplines/:subject_id',                      to: 'redirect#city_subject'
  get 'ville/:city_id/cours/:subject_id',                            to: 'redirect#city_subject'
  get 'ville/:id',                                                   to: 'redirect#city'
  get 'disciplines/:id',                                             to: 'redirect#disciplines'

  # ------------------------------------------------------
  # ----------------------------------------- Static pages
  # ------------------------------------------------------
  # Pages
  get 'pages/pourquoi-le-bon-cours',        to: 'redirect#why_coursavenue'
  get 'pages/pourquoi-coursavenue'          => 'pages#why',                  as: 'pages_why'
  get 'pages/comment-ca-marche'             => 'pages#how_it_works',         as: 'pages_how_it_works'
  get 'pages/faq-utilisateurs'              => 'pages#faq_users',            as: 'pages_faq_users'
  get 'pages/faq-partenaires'               => 'pages#faq_partners',         as: 'pages_faq_partners'
  get 'pages/qui-sommes-nous'               => 'pages#who_are_we',           as: 'pages_who_are_we'
  get 'pages/contact'                       => 'pages#contact'
  get 'pages/service-client'                => 'pages#customer_service',     as: 'pages_customer_service'
  get 'pages/presse'                        => 'pages#press',                as: 'pages_press'
  get 'pages/jobs'                          => 'pages#jobs'
  get 'pages/mentions-legales-partenaires'  => 'pages#mentions_partners',    as: 'pages_mentions_partners'
  get 'pages/conditions-generale-de-vente'  => 'pages#terms_and_conditions', as: 'pages_terms_and_conditions'

  get '/musique', to: 'structures#index', subject_id: 'musique-chant'
  get '/danse', to: 'structures#index'  , subject_id: 'danse'
  get '/theatre', to: 'structures#index', subject_id: 'theatre'

  get '/blog' => redirect('/blog/')

  post 'contact/' => 'home#contact'

  root :to => 'home#index'
end
