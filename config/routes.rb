# encoding: utf-8
CoursAvenue::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  mount_griddler
  get "/email_processor", to: proc { [200, {}, ["OK"]] }, as: "mandrill_head_test_request"
  get '/robots.txt' => 'home#robots'
  # ---------------------------------------------
  # ----------------------------------------- PRO
  # ---------------------------------------------
  constraints subdomain: (Rails.env.staging? ? 'pro.staging' : 'pro') do
    namespace :pro, path: '' do
      root :to => 'home#index'

      get '/premium'                            => 'redirect#structures_premium'

      get 'offre-speciale-premiers-partenaires' => 'home#july_offer',         as: 'pages_july_offer'
      get 'livres-blancs'                       => 'home#white_book',         as: 'pages_white_books'
      get 'mailjet_custo'                       => 'home#mailjet_custo'
      get 'pourquoi-etre-recommande'            => 'home#why_be_recommended', as: 'pages_why_be_recommended'
      get 'livre-d-or'                          => 'home#widget',             as: 'pages_widget'
      get 'questions-les-plus-frequentes'       => 'home#questions',          as: 'pages_questions'
      get 'pass-decouverte'                     => 'home#discovery_pass',     as: 'pages_discovery_pass'
      get 'fonctionnalites'                     => 'home#features',           as: 'pages_features'
      get 'offre-et-tarifs'                     => 'home#price',              as: 'pages_price'
      get 'nos-convictions'                     => 'home#convictions',        as: 'pages_convictions'
      get 'presse'                              => redirect('presse', subdomain: 'www', status: 301)
      get 'portes-ouvertes-cours-loisirs'       => 'home#jpo',                as: 'pages_jpo'
      get 'journees-portes-ouvertes'            => redirect('pages/portes-ouvertes-cours-loisirs', status: 301)
      get '/dashboard'                          => 'dashboard#index',         as: 'dashboard'
      get 'cours-d-essai-gratuits'              => 'home#free_trial',         as: 'pages_free_trial'

      # Redirect old pages
      get 'pages/offre-speciale-premiers-partenaires' => redirect('offre-speciale-premiers-partenaires', status: 301)
      get 'pages/livres-blancs'                       => redirect('livres-blancs'                      , status: 301)
      get 'pages/pourquoi-etre-recommande'            => redirect('pourquoi-etre-recommande'           , status: 301)
      get 'pages/presentation'                        => redirect('/'                                  , status: 301)
      get 'pages/livre-d-or'                          => redirect('livre-d-or'                         , status: 301)
      get 'pages/questions-les-plus-frequentes'       => redirect('questions-les-plus-frequentes'      , status: 301)
      get 'pages/offre-et-tarifs'                     => redirect('offre-et-tarifs'                    , status: 301)
      get 'pages/nos-convictions'                     => redirect('nos-convictions'                    , status: 301)
      get 'pages/presse'                              => redirect('presse'                             , status: 301)
      get 'pages/portes-ouvertes-cours-loisirs'       => redirect('portes-ouvertes-cours-loisirs'      , status: 301)
      get 'pages/journees-portes-ouvertes'            => redirect('journees-portes-ouvertes'           , status: 301)


      # 301 Redirection
      get 'etablissements/demande-de-recommandations', to: 'redirect#structures_new'
      get 'inscription'                              , to: 'structures#new'
      get 'sms'                                      , to: 'structures#new'

      get 'tableau-de-bord'                          , to: 'redirect#structure_dashboard', as: 'structure_dashboard_redirect'
      get 'modifier-mon-profil'                      , to: 'redirect#structure_edit',      as: 'structure_edit_redirect'
      get 'etablissements/:structure_id/journees-portes-ouvertes', to: 'redirect#structures_jpo_index'

      resources :call_reminders
      resources :portraits, controller: 'portraits' do
        collection do
          get :list
        end
        resources :medias, controller: 'portraits/medias'
      end

      resources :discovery_passes, only: [:index]
      resources :participation_requests, only: [:index]
      resources :sponsorships, only: [:index]
      resources :payment_notifications, only: [:index, :show]
      resources :blog_articles, controller: 'blog/articles', path: 'blog'
      resources :press_releases, path: 'communiques-de-presse'
      resources :press_articles
      resources :flyers, only: [:index, :update]
      resources :faqs do
        collection do
          get :preview
        end
      end
      resources :metrics, only: [] do
        collection do
          get :comments
          get :jpos
          get :admins_count
          get :comments_count
          get :jpo_courses_count
          get :reco_count
          get :users_count
        end
      end

      resources :comments, only: [:edit, :update, :index, :destroy] do
        member do
          patch :recover
        end
      end

      resources :vertical_pages, path: 'pages-verticales'
      resources :city_subject_infos, only: [:new, :create]
      resources :cities, only: [:index, :edit, :update], path: 'villes' do
        collection do
          get :zip_code_search
        end
      end
      resources :keywords, only: [:index, :create, :destroy]
      resources :search_term_logs, only: [:index]
      resources :subjects do
        member do
          get :edit_name
          get :completion
        end
        collection do
          get :all
          get :descendants
        end
      end

      resources :emailings do
        resources :sections, only: [:index]
        resources :bridges, only: [:update]
        member do
          get :preview
          get :code
          get :send_preview, path: 'send'
        end
      end


      resources :reservations, only: [:index]
      resources :invited_users, only: [:index]
      resources :sticker_demands, only: [:index]
      resources :open_courses, only: [:index], controller: 'open_courses' do
        collection do
          get :fulfillment
          get :fulfillment_per_courses
        end
      end
      resources :participations, only: [:index], controller: 'participations'
      resources :statistics, only: [:index]
      resources :promotion_codes, path: 'code-promos'

      resources :subscription_plans, only: [:index, :update], path: 'abonnements' do
        collection do
          get :premium_tracking, path: 'suivi-premium'
          get :unsubscribed_tracking, path: 'suivi-desabo'
          get :download
        end
        member do
          get :stat_info
        end
      end
      resources :payments, path: 'paiement', only: [] do
        collection do
          post :paypal_notification
          get  :paypal_confirmation
          get  :be2bill_confirmation
          post :be2bill_notification
          post :be2bill_placeholder
        end
      end

      resources :structures, path: 'etablissements' do
        member do
          get   :edit_order_recipient
          get   :someone_already_took_control, path: 'quelqu-un-a-deja-le-control'
          get   :dont_want_to_take_control_of_my_sleeping_account, path: 'me-desabonner'
          get   :add_subjects
          get   :ask_for_deletion
          get   :confirm_deletion
          get   :crop_logo
          get   :dashboard, path: 'tableau-de-bord'
          get   :edit_contact, path: 'informations-contact'
          get   :logo
          get   :payment_confirmation, path: 'confirmation-paiement'
          get   :premium_modal
          get   :recommendations, path: 'recommendations'
          get   :signature
          get   :update_widget_status
          patch :wake_up
          patch :return_to_sleeping_mode
          get   :widget
          get   :wizard
          get   :widget_jpo
          match :widget_ext, controller: 'structures', via: [:options, :get], as: 'widget_ext'
          match :widget_jpo_ext, controller: 'structures', via: [:options, :get], as: 'widget_jpo_ext'
          patch :update_and_delete
          post  :recommend_friends
          post  :update
          get   :premium # redirect to subscriptions
        end
        collection do
          get :sleepings
          get :stars
          get :best
          get :inscription, to: :new
        end
        devise_for :admins, controllers: { registrations: 'pro/admins/registrations'}, path: '/', path_names: { registration: 'rejoindre-coursavenue-pro', sign_up: '/' }
        resources :orders, only: [:index, :show], controller: 'structures/orders', path: 'mes-factures' do
          member do
            get 'export'
          end
        end
        resources :subscription_plans, only: [:new, :index, :destroy], controller: 'structures/subscription_plans', path: 'abonnements' do
          collection do
            get :choose_premium, path: 'choisir-un-abonnement'
            get :paypal_express_checkout
            get :paypal_confirmation
          end
          member do
            patch :reactivate
            get :ask_for_cancellation
            get :confirm_cancellation
          end
        end
        resources :participations, only: [:index], controller: 'structures/participations' do
          member do
            patch :pop_from_waiting_list
          end
        end
        resources :admins, controller: 'structures/admins' do
          member do
            get :modify_email
            get :notifications
          end
          collection do
            get 'unsubscribe/:signature' => 'admins#unsubscribe', as: 'unsubscribe'
          end
        end
        resources :sticker_demands, only: [:create, :new, :index], controller: 'structures/sticker_demands' do
          member do
            put :update_sent
          end
        end

        resources :user_profiles, controller: 'structures/user_profiles', path: 'repertoire' do
          collection do
            post :import_batch_emails
          end
        end
        resources :bulk_user_profile_jobs, controller: 'structures/bulk_user_profile_jobs', path: 'bulk', only: [:create, :index, :new]
        resources :tags, controller: 'structures/tags', path: 'tags'
        resources :user_profile_imports, only: [:new, :create], controller: 'structures/user_profile_imports', path: 'import-carnet-adresses' do
          member do
            get   :choose_headers
            patch :import
          end
        end
        resources :invited_teachers, only: [:index, :new, :destroy], controller: 'structures/invited_teachers', path: 'parrainage-professeurs' do
          collection do
            post :bulk_create
          end
        end
        resources :invited_students, only: [:index, :new, :destroy], controller: 'structures/invited_students' do
          collection do
            post :bulk_create
            post :bulk_create_jpo
            get :jpo_new
            get :jpo
          end
        end

        resources :newsletters, only: [:index, :update, :create], controller: 'structures/newsletters' do
          resources :blocs, only: [:create, :update, :destroy], controller: 'structures/newsletters/blocs'
          member do
            get :send_newsletter
            get :duplicate
            get :preview_newsletter
            get :mailing_list
            get :metadata

            post :mailing_list_create
            patch :save_and_send
          end

          collection do
            get '*path', to: 'structures/newsletters#new'
          end
        end

        resources :comment_notifications, controller: 'structures/comment_notifications'
        resources :comments, only: [:index], controller: 'structures/comments', path: 'avis' do
          member do
            patch :highlight
            patch :accept
            patch :decline
            patch :ask_for_deletion
          end
          resources :comment_replies, controller: 'structures/comments/comment_replies' do
            member do
              get :ask_for_deletion
            end
          end
        end
        resources :medias, only: [:edit, :update, :index, :destroy], controller: 'structures/medias', path: 'photos-videos' do
          member do
            put :make_it_cover
          end
        end
        resources :videos, only: [:create, :new], controller: 'structures/medias/videos'
        resources :images, only: [:create, :new], controller: 'structures/medias/images'

        resources :teachers, controller: 'structures/teachers', path: 'professeurs'
        resources :places  , controller: 'structures/places'  , path: 'lieux' do
          member do
            get :edit_infos
            get :ask_for_deletion
          end
        end

        resources :messages     , controller: 'structures/messages'
        resources :conversations, controller: 'structures/conversations' do
          member do
            patch :treat_by_phone
            get   :treat_by_phone # Accept get for when user come by email
            patch :flag
            get   :flag
          end
        end
        resources :statistics   , controller: 'structures/statistics', only: [:index], path: 'statistiques'

        resources :price_groups, path: 'tarifs', controller: 'structures/price_groups' do
          member do
            get :ask_for_deletion
            put :add_course
            put :remove_course
          end
        end
        resources :courses, path: 'cours', controller: 'structures/courses' do
          collection do
            get :trainings, path: 'stages'
            get :regular, path: 'reguliers'
            get :trial_courses, path: 'essais'
          end
          member do
            get  :ask_for_deletion
          end
          resources :plannings, controller: 'structures/courses/plannings'
          resources :book_tickets, only: [:edit, :index, :destroy]
          member do
            patch :update_price
            patch :activate
            patch :disable
            patch :activate_ok_nico
            patch :disable_ok_nico

          end
        end
        resources :course_opens, path: 'portes-ouvertes-cours-loisirs', controller: 'structures/open_courses' do
          collection do
            get :communicate, path: 'communiquer'
            get :ca_communication, path: 'communication-coursavenue'
          end
        end
        resources :participation_requests, only: [:edit, :index, :show], controller: 'structures/participation_requests', path: 'suivi-inscriptions' do
          member do
            get   :report_form
            get   :cancel_form
            get   :accept_form
            patch :accept
            patch :discuss
            patch :modify_date
            patch :cancel
            patch :report
          end
        end
      end
      resources :visitors, only: [:index, :show]
      resources :users, only: [:index] do
        member do
          patch :activate
        end
      end
      resources :comment_notifications, only: [:index]
      resources :conversations        , only: [:index]

      get '/auth/facebook/callback', to: 'admins#facebook_auth_callback'
      get '/auth/failure',           to: 'admins#facebook_auth_failure'

      resources :admins do
        collection do
          get :waiting_for_activation, path: 'activez-votre-compte'
        end
        member do
          patch 'confirm'
        end
      end
      devise_for :admins, controllers: { sessions: 'pro/admins/sessions', registrations: 'pro/admins/registrations', passwords: 'pro/admins/passwords', confirmations: 'pro/admins/confirmations'}, path: '/', path_names: { sign_in: '/connexion', sign_out: 'logout', registration: 'rejoindre-coursavenue-pro', sign_up: '/', :confirmation => 'verification'}#, :password => 'secret', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }

      get "/contacts/:importer/callback", to: "contacts#callback"
      get "/contacts/failure",            to: "contacts#failure"
    end
  end

  # ---------------------------------------------
  # ----------------------------------------- WWW
  # ---------------------------------------------
  constraints subdomain: (Rails.env.staging? ? 'staging' : 'www') do
    resources :press_releases, path: 'communiques-de-presse', only: [:show]
    resources :blog_articles, controller: 'blog/articles', path: 'blog' do
      collection do
        get 'tag/:tag', to: 'blog/articles#tags', as: :tags
      end
    end

    devise_for :users, controllers: {
                        sessions: 'users/sessions',
                        registrations: 'users/registrations',
                        confirmations: 'users/confirmations',
                        passwords: 'users/passwords'
                      }, path: '/', path_names: {
                        sign_in: '/connexion',
                        sign_up: '/inscription',
                        confirmation: 'verification'
                      }


    get '/auth/facebook/callback', to: 'users#facebook_auth_callback'
    get '/auth/facebook/failure',  to: 'users#facebook_auth_failure'

    resources  :users, only: [:destroy, :create, :edit, :show, :update], path: 'eleves' do
      collection do
        get :unsubscribed
        get :invite_entourage_to_jpo_page , path: 'inviter-mes-amis'
        get 'unsubscribe/:signature' => 'users#unsubscribe', as: 'unsubscribe'
        get 'activez-votre-compte'   => 'users#waiting_for_activation', as: 'waiting_for_activation'
        get :welcome
      end
      member do
        get    :destroy_confirmation
        get    :edit_private_infos, path: 'mon-compte'
        patch  :update_password
        patch  :update_passions
        get  :wizard
        get  :dashboard
        get  :choose_password
        post :recommend_friends
      end
      resources :followings, only: [:index], controller: 'users/followings', path: 'favoris'
      resources :invited_users, only: [:index, :new], controller: 'users/invited_users' do
        collection do
          post :bulk_create
          post :bulk_create_jpo
          get :jpo_new
          get :jpo
        end
      end
      resources :comments, only: [:index, :edit, :update], controller: 'users/comments'
      resources :messages     , controller: 'users/messages'
      resources :conversations, controller: 'users/conversations'
      resources :lived_places, only: [:destroy], controller: 'users/lived_places'
      resources :passions, only: [:index, :destroy], controller: 'users/passions' do
        collection do
          get :offers
          get :suggestions
        end
      end
      resources :participations, only: [:update, :index, :destroy], controller: 'users/participations' do
        member do
          get   :add_invited_friends
        end
      end
      resources :orders, only: [:index, :show], controller: 'users/orders', path: 'mes-factures'
      resources :sponsorships, only: [:index, :new, :create], controller: 'users/sponsorships', path: 'mes-parrainages'
      resources :participation_requests, only: [:index, :edit, :show], controller: 'users/participation_requests', path: 'mes-inscriptions' do
        member do
          get   :report_form
          get   :cancel_form
          get   :accept_form
          patch :accept
          patch :discuss
          patch :modify_date
          patch :cancel
          patch :report
        end
      end
    end
    resources :sponsorships, only: [:show], path: 'obtenir-mon-pass-decouverte'
    resources :emails, only: [:create]

    resources :visitors, only: [:create, :update, :index]

    resources :plannings, only: [] do
      resources :participations, only: [:new, :create], controller: 'plannings/participations'
    end
    resources :locations, only: [:index]

    resources :reservations, only: [:create]

    resources :open_courses, path: 'portes-ouvertes-cours-loisirs', only: [:index], controller: 'open_courses'

    resources :statistics, only: [:create]

    resources :structures, only: [:show, :index], path: 'etablissements', controller: 'structures' do
      member do
        get  :jpo, path: 'portes-ouvertes-cours-loisirs'
        post :add_to_favorite
        post :remove_from_favorite
      end
      collection do
        post :recommendation
        get :search
        get :typeahead
      end
      resources :participation_requests, only: [:create]                                    , controller: 'structures/participation_requests'
      resources :statistics            , only: [:create]                                    , controller: 'structures/statistics'
      resources :messages              , only: [:create]                                    , controller: 'structures/messages'
      resources :places                , only: [:index]                                     , controller: 'structures/places'
      resources :courses               , only: [:show, :index]                              , controller: 'structures/courses'    , path: 'cours'
      resources :comments              , only: [:create, :new, :show, :index, :update]      , controller: 'structures/comments'   , path: 'avis' do
        collection do
          get :create_from_email
        end
        member do
          get :add_private_message, path: 'envoyer-un-message-prive'
        end
      end
      resources :newsletter, only: [:show]

      # Here for old 404
      resources :comments              , only: [:new]                                       , controller: 'structures/comments'   , path: 'recommendations'
      resources :comments              , only: [:new]                                       , controller: 'structures/comments'   , path: 'recommandations'
      resources :teachers              , only: [:index]                                     , controller: 'structures/teachers'
      resources :medias                , only: [:index]                                     , controller: 'structures/medias'
    end

    resources :courses, only: [:index], path: 'cours' do
      resources :reservations, only: [:new, :create] # Redirection 301 in controller
    end

    resources :keywords, only: [:index]
    resources :reply_token, only: [:show]

    ########### Vertical pages ###########
    get 'cours/:id--:city_id'                        , to: 'vertical_pages#show_with_city'  , as: :root_vertical_page_with_city
    get 'cours/:id'                                  , to: 'vertical_pages#show_root'       , as: :root_vertical_page
    get 'cours/:root_subject_id/:id'                 , to: 'vertical_pages#show'            , as: :vertical_page
    get 'cours/:root_subject_id/:id/:city_id'        , to: 'vertical_pages#show_with_city'  , as: :vertical_page_with_city
    get 'cours-de-:id'                               , to: 'vertical_pages#redirect_to_show'
    get 'cours-de-:id-a/:city_id--:old_slug'         , to: 'redirect#structures_index'
    get 'guide-des-disciplines'                      , to: 'vertical_pages#index'           , as: :vertical_pages
    ########### Vertical pages ###########

    resources :cities, only: [], path: 'villes' do
      collection do
        get :zip_code_search
      end
    end
    resources :cities, only: [:show], path: 'tous-les-cours-a', controller: 'cities' do
      resources :subjects, only: [:show], path: 'disciplines'
    end

    resources :subjects, only: [] do
      collection do
      end
    end
    resources :subjects, only: [:index] do
      member do
        get :depth_2
      end
      collection do
        get :list
        get :descendants
        get :search
      end
      resources :structures, only: [:index], path: 'etablissements'
      # resources :places, only: [:index], path: 'etablissements'
      resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index' # établissement without S
      resources :courses, only: [:index], path: 'cours'
    end

    resources :reservation_loggers, only: [:create]
    resources :click_logs, only: [:create]

    # ------------------------------------------------------
    # ----------------------------------------- Static pages
    # ------------------------------------------------------
    # Pages
    get 'vos-resolutions-2015'               => 'home#resolutions',          as: 'home_resolutions'
    get 'vos-resolutions-2015/resultats/:id' => 'home#resolutions_results',  as: 'home_resolutions_results'

    get 'mon-compte'                    => 'home#redirect_to_account'
    get 'pourquoi-le-bon-cours',        to: 'redirect#why_coursavenue'
    get 'portes-ouvertes-cours-loisirs' => 'pages#jpo',                  as: 'pages_jpo'
    get 'comment-ca-marche'             => 'pages#what_is_it',           as: 'pages_what_is_it'
    get 'faq-utilisateurs'              => 'pages#faq_users',            as: 'pages_faq_users'
    get 'faq-partenaires'               => 'pages#faq_partners',         as: 'pages_faq_partners'
    get 'qui-sommes-nous'               => 'pages#who_are_we',           as: 'pages_who_are_we'
    get 'contact'                       => 'pages#contact',              as: 'pages_contact'
    get 'service-client'                => 'pages#customer_service',     as: 'pages_customer_service'
    get 'presse'                        => 'pages#press',                as: 'pages_press'
    get 'mentions-legales-partenaires'  => 'pages#mentions_partners',    as: 'pages_mentions_partners'
    get 'conditions-generale-de-vente'  => 'pages#terms_and_conditions', as: 'pages_terms_and_conditions'
    get 'cours-d-essai-gratuits'        => 'pages#free_trial',           as: 'pages_free_trial'

    # Jobs
    get 'jobs'                          => 'jobs#index'
    get 'jobs/frontend-developpeur'     => 'jobs#frontend_developper',   as: 'jobs_frontend_developper'
    get 'jobs/business-developpeur'     => 'jobs#business_developper',   as: 'jobs_business_developper'
    get 'jobs/marketing'                => 'jobs#marketing',             as: 'jobs_marketing'

    # Redirect old pages
    get 'pages/pourquoi-le-bon-cours'         => redirect('pourquoi-le-bon-cours'         , status: 301)
    get 'pages/portes-ouvertes-cours-loisirs' => redirect('portes-ouvertes-cours-loisirs' , status: 301)
    get 'qu-est-ce-que-coursavenue'           => redirect('comment-ca-marche'             , status: 301)
    get 'pages/qu-est-ce-que-coursavenue'     => redirect('qu-est-ce-que-coursavenue'     , status: 301)
    get 'pages/faq-utilisateurs'              => redirect('faq-utilisateurs'              , status: 301)
    get 'pages/faq-partenaires'               => redirect('faq-partenaires'               , status: 301)
    get 'pages/qui-sommes-nous'               => redirect('qui-sommes-nous'               , status: 301)
    get 'pages/contact'                       => redirect('contact'                       , status: 301)
    get 'pages/service-client'                => redirect('service-client'                , status: 301)
    get 'pages/presse'                        => redirect('presse'                        , status: 301)
    get 'pages/jobs'                          => redirect('jobs'                          , status: 301)
    get 'pages/mentions-legales-partenaires'  => redirect('mentions-legales-partenaires'  , status: 301)
    get 'pages/conditions-generale-de-vente'  => redirect('conditions-generale-de-vente'  , status: 301)
    get 'pass-decouverte'                     => redirect('comment-ca-marche'             , status: 301)

    post 'contact/' => 'pages#send_message'

    post '/mandrill-webhook' => 'mandrill_webhook#create'
    get  '/mandrill-webhook' => 'mandrill_webhook#index'
    root :to => 'home#index'

    ########### Search pages ###########
    # Must be at the end not to stop other routes
    # Redirect cities that have been deleted and have slug like 'tours--57'
    get ':root_subject_id/:subject_id--:city_id--:old_city_slug', to: 'redirect#structures_index'
    get ':root_subject_id--:city_id--:old_city_slug'            , to: 'redirect#structures_index'
    # end-redirect
    get ':root_subject_id/:subject_id--:city_id'                , to: 'structures#index', as: :search_page
    get ':root_subject_id--:city_id'                            , to: 'structures#index', as: :root_search_page
    get ':city_id'                                              , to: 'structures#index', as: :root_search_page_without_subject
    ########### Search pages ###########

    # Needed to catch 404 requests in ApplicationController
    # match "*path", to: "application#routing_error", via: :get
  end

  # ---------------------------------------------
  # -----------------------------------END OF WWW
  # ---------------------------------------------

  get '/', to: 'redirect#www_root'
  ########### Search pages ###########
  # Redirect if it's not on WWW subdomain
  # Redirect cities that have been deleted and have slug like 'tours--57'
  get ':root_subject_id/:subject_id--:city_id--:old_city_slug', to: 'redirect#structures_index'
  get ':root_subject_id--:city_id--:old_city_slug'            , to: 'redirect#structures_index'
  get ':root_subject_id/:subject_id--:city_id'                , to: 'redirect#structures_index'
  get ':root_subject_id--:city_id'                            , to: 'redirect#structures_index'
  get ':city_id'                                              , to: 'redirect#structures_index'
  ########### Search pages ###########


  # ---------------------------------------------------------
  # ----------------------------------------- Redirection 301
  # ---------------------------------------------------------
  # Catching all 301 redirection
  resources :subjects, only: [:index], path: 'cours' do
    resources :cities, only: [:show], path: 'a', to: 'redirect#vertical_page_subject_city'
  end
  resources :subjects, only: [], path: 'disciplines' do
    resources :cities, only: [:show], path: 'villes', to: 'redirect#vertical_page_subject_city'
    member do
      get 'cours', to: 'redirect#vertical_page'
    end
  end
  resources :subjects, only: [], path: 'disciplines' do
    resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index'
  end
  resources :places, only: [:show],  path: 'etablissement',          to: 'redirect#place_show' # établissement without S
  resources :places, only: [:index], path: 'etablissement',          to: 'redirect#place_index' # établissement without S
  get 'lieux',                                                       to: 'redirect#lieux'
  get 'lieux/:id',                                                   to: 'redirect#lieux_show'
  get 'ville/:city_id/disciplines/:subject_id',                      to: 'redirect#city_subject'
  get 'ville/:city_id/cours/:subject_id',                            to: 'redirect#city_subject'
  get 'ville/:id',                                                   to: 'redirect#city'

  ########### Vertical pages ###########
  get 'cours/:id--:city_id'                        , to: 'redirect#vertical_pages__show_with_city'
  get 'cours/:id'                                  , to: 'redirect#vertical_pages__show_root'
  get 'cours/:root_subject_id/:id'                 , to: 'redirect#vertical_pages__show'
  get 'cours/:root_subject_id/:id/:city_id'        , to: 'redirect#vertical_pages__show_with_city'
  get 'cours-de-:id'                               , to: 'vertical_pages#redirect_to_show'
  get 'guide-des-disciplines'                      , to: 'redirect#vertical_pages__index'
  ###########  REDIRECTIONS --old
  ## With city
  # Root subject
  get 'cours-de-:subject_id-a/:id'                 , to: 'subjects/cities#show', as: :vertical_root_subject_city
  # Child subject
  get 'cours-de-:parent_subject_id/:subject_id/:id', to: 'subjects/cities#show', as: :vertical_subject_city
  ## Without city
  # Child subject
  get 'cours-de-:parent_subject_id/:id'            , to: 'subjects#show'       , as: :vertical_subject
  ########### Vertical pages ###########
end
