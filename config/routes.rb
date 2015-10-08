# encoding: utf-8
CoursAvenue::Application.routes.draw do

  mount_griddler
  get "/email_processor", to: proc { [200, {}, ["OK"]] }, as: "mandrill_head_test_request"
  get '/robots.txt' => 'home#robots'


  # ---------------------------------------------
  # ----------------------------------------- PRO
  # ---------------------------------------------
  constraints subdomain: 'pro' do
    # For super admin
    namespace :admin do
      resources :users, only: [:index]
      resources :flyers, only: [:index, :update]
      resources :press_articles
      resources :newsletters, only: [:index]
      resources :blog_articles, controller: 'blog/articles', path: 'blog' do
        resources :medias, controller: 'blog/articles/medias'
      end
      resources :blog_categories, only: [:new, :create, :edit, :update, :destroy], controller: 'blog/categories'
      resources :blog_authors, only: [:new, :create, :edit, :update, :destroy], controller: 'blog/authors', path: 'blog/auteurs'
      resources :images, only: [:index, :create]
      resource  :community             , only: [:show]                                     , controller: 'structures/community'      , path: 'communaute' do
        resources :message_threads, only: [:index, :destroy], controller: 'community/message_threads' do
          member do
            post :approve
            post :privatize
          end
        end
      end
      resources :sms_loggers, only: [:index, :show]
      resources :places, only: [:index]
    end

    # For pros
    namespace :pro, path: '' do
      root :to => 'home#index'

      get 'livres-blancs'                       => 'home#white_book',         as: 'pages_white_books'
      get 'mailjet_custo'                       => 'home#mailjet_custo'
      get 'pourquoi-etre-recommande'            => 'home#why_be_recommended', as: 'pages_why_be_recommended'
      get 'livre-d-or'                          => 'home#widget',             as: 'pages_widget'
      get 'questions-les-plus-frequentes'       => 'home#questions',          as: 'pages_questions'
      get 'fonctionnalites'                     => 'home#features',           as: 'pages_features'
      get 'offre-et-tarifs'                     => 'home#price',              as: 'pages_price'
      get 'nos-convictions'                     => 'home#convictions',        as: 'pages_convictions'
      get 'presse'                              => redirect('presse', subdomain: 'www', status: 301)
      get 'journees-portes-ouvertes'            => redirect('pages/portes-ouvertes-cours-loisirs', status: 301)
      get '/dashboard'                          => 'dashboard#index',         as: 'dashboard'
      get '/dashboard-2'                        => 'dashboard#stats'
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

      resources :participation_requests, only: [:index]
      resources :blog_subscribers, only: [:create], controller: 'blog/subscribers'
      resources :blog_articles, only: [:index, :show], controller: 'blog/articles', path: 'blog' do
        collection do
          get 'tag/:tag'                , to: 'blog/articles#tags', as: :tags
          get 'categories/pour-vous-et-vos-boud-choux', to: 'redirect#blog'
          get 'categories/le-tour-du-monde-en-80-cours', to: 'redirect#blog'
          get 'categories/:category_id' , to: 'blog/articles#category_index', as: :category
        end
      end

      resources :press_releases, path: 'communiques-de-presse'

      resources :faqs do
        collection do
          get :preview
        end
      end

      resources :comments, only: [:edit, :update, :index] do
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
      resources :subjects do
        member do
          get :edit_name
        end
        collection do
          get :descendants
          get :all
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

      resources :invited_users, only: [:index]
      resources :sticker_demands, only: [:index]

      resources :subscriptions,          only: [:index]
      resources :subscriptions_invoices, only: [:index]
      resources :subscriptions_coupons, only: [:index, :new, :create, :destroy, :show] do
        member do
          get :check
        end
      end
      resources :subscriptions_plans do
        member do
          get :subscriptions
        end
      end
      resources :subscriptions_sponsorships, only: [:show], path: 'parrainage'

      get 'nouveau-dormant', to: 'structures#new_sleeping', as: :add_sleeping_structure
      resources :registrations, only: [:new, :create], path: 'inscriptions' do
        collection do
          get :new_course
          post :create_course
        end
      end
      resources :structures, path: 'etablissements' do
        collection do
          get :stars
          get :inscription, to: :new
          post :import
          get :imported_structures
          get :duplicates
          post :update_duplicates
        end
        member do
          get   :ask_for_pro_deletion
          get   :confirm_email
          post  :resend_confirmation_instructions
          get   :dashboard, path: 'tableau-de-bord'
          get   :old_dashboard_path, path: 'dashboard', to: 'redirect#old_dashboard_path'
          get   :edit_order_recipient
          get   :someone_already_took_control, path: 'quelqu-un-a-deja-le-control'
          get   :add_subjects
          get   :ask_for_deletion
          get   :confirm_deletion
          get   :crop_logo
          get   :edit_contact, path: 'informations-contact'
          get   :logo
          get   :recommendations, path: 'recommendations'
          get   :signature
          get   :communication
          get   :widget
          get   :wizard
          match :widget_ext, controller: 'structures', via: [:options, :get], as: 'widget_ext'
          patch :update_and_delete
          post  :recommend_friends
          post  :ask_webmaster_for_planning
          post  :update
          get   :website_planning, path: 'planning-sur-mon-site'
          get   :website_planning_parameters, path: 'parametre-de-mon-planning-sur-mon-site'
          get   :enabling_confirmation
          patch :enable
          get   :cards
        end
        resources :website_parameters, except: [:destroy], path: 'site-internet', controller: 'structures/website_parameters'
        resources :website_pages, path: 'pages-personnalisees', controller: 'structures/website_pages' do
          resources :website_page_articles, as: :articles, path: 'articles', controller: 'structures/website_pages/articles'
        end

        devise_for :admins, controllers: { registrations: 'pro/admins/registrations'}, path: '/', path_names: { registration: 'rejoindre-coursavenue-pro', sign_up: '/' }
        resources :invoices, only: [:index], controller: 'structures/invoices', path: 'factures' do
          member do
            get :download
          end
        end
        # New subscriptions with Stripe
        resources :subscriptions, only: [:index, :create, :destroy], controller: 'structures/subscriptions', path: 'mon-abonnement' do
          member do
            patch :activate
            get   :choose_new_plan
            patch :change_plan
            get   :confirm_cancellation
            patch :reactivate
            get   :stripe_payment_form
          end
          collection do
            get   :confirm_choice
            patch :accept_payments
            patch :update_payments
            get   :accept_payments_form
            get   :update_payments_form
            get   :choose_plan_and_pay
            resources :subscriptions_sponsorships, only: [:index, :create], controller: 'structures/subscriptions_sponsorships', path: 'parrainage'
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

        resources :tags, controller: 'structures/tags', path: 'tags'
        resources :invited_teachers, only: [:index, :new, :destroy], controller: 'structures/invited_teachers', path: 'parrainage-professeurs' do
          collection do
            post :bulk_create
          end
        end
        resources :invited_students, only: [:index, :new, :destroy], controller: 'structures/invited_students' do
          collection do
            post :bulk_create
          end
        end

        resources :mailing_lists, controller: 'structures/mailing_lists', path: 'listes-de-diffusion' do
          resources :user_profiles, only: [:destroy], controller: 'structures/mailing_lists/user_profiles'
        end

        resources :newsletters, only: [:index, :new, :create, :edit, :update, :destroy], controller: 'structures/newsletters' do
          resources :blocs, only: [:create, :update, :destroy], controller: 'structures/newsletters/blocs' do
            resources :sub_blocs, only: [], controller: 'structures/newsletters/blocs' do
              member do
                put :update, to: 'structures/newsletters/blocs#sub_bloc_update'
              end
              collection do
                post :create, to: 'structures/newsletters/blocs#sub_bloc_create'
              end
            end
          end
          resources :mailing_lists, only: [:create, :update, :edit], controller: 'structures/newsletters/mailing_lists' do
            collection do
              post :file_import
              patch :update_headers

              post :bulk_import
            end
          end
          member do
            get :duplicate
            get :preview_newsletter
            get :confirm
            get :send_newsletter
            get :metrics

            get 'liste-de-diffusion', to: 'structures/newsletters#new', as: 'mailing_list'
            get :recapitulatif,       to: 'structures/newsletters#new', as: 'metadata'
          end
          collection do
            get ':id/*path', to: 'structures/newsletters#new'
            get '*path',     to: 'structures/newsletters#new'
          end
        end

        resources :comment_notifications, controller: 'structures/comment_notifications'
        resources :comments, only: [:index, :destroy], controller: 'structures/comments', path: 'avis' do
          member do
            patch :highlight
            patch :ask_for_deletion
          end
          collection do
            get :comments_on_website, path: 'livre-d-or'
          end
          resources :comment_replies, controller: 'structures/comments/comment_replies' do
            member do
              get :ask_for_deletion
            end
          end
        end
        resources :redactor_images, only: [:index, :create], controller: 'structures/redactor_images'
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
            get :configure_openings
            patch :update_openings
            post :generate_cards
          end
          member do
            get   :choose_media
            patch :add_image
            get   :ask_for_deletion
            patch :update_price
          end
          resources :plannings, controller: 'structures/courses/plannings'
          resources :book_tickets, only: [:edit, :index, :destroy]
        end
        resources :participation_requests, only: [:edit, :index, :show], controller: 'structures/participation_requests', path: 'suivi-inscriptions' do
          member do
            get   :cancel_form
            get   :accept_form
            patch :accept
            patch :discuss
            patch :modify_date
            patch :cancel
            get   :show_user_contacts
            get   :rebook_form
            patch :rebook
            patch :signal_user_absence
          end
          collection do
            get :paid_requests, path: 'transactions-cb'
            get :upcoming, path: 'a-venir'
            get :past,     path: 'deja-passee'
          end
        end
        resources :gift_certificates, only: [:index, :edit, :new, :create, :destroy, :update], controller: 'structures/gift_certificates', path: 'bons-cadeaux' do
          collection do
            get :install_guide
            get :confirm_use_voucher
            post :use_voucher
          end
        end
      end
      resources :comment_notifications, only: [:index]
      resources :conversations        , only: [:index]

      get '/auth/facebook/callback', to: 'admins#facebook_auth_callback'
      get '/auth/failure',           to: 'admins#facebook_auth_failure'

      resource :onboarding, controller: 'admins/onboarding', only: [:update] do
        collection do
          get :step_zero
          get :step_one
          get :step_two
          get :step_three
          get :step_four
          get :step_five
        end
      end

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

      resources :guides do
        member do
          get :edit_subjects
          patch :update_subjects
        end
      end

    end
  end

  # ---------------------------------------------
  # ----------------------------------------- WWW
  # ---------------------------------------------
  constraints subdomain: 'www' do
    get 'stages', to: redirect('/paris?type=training&locate_user=on')

    resources :press_releases, path: 'communiques-de-presse', only: [:show]

    resources :blog_subscribers, only: [:create], controller: 'blog/subscribers'
    resources :blog_articles, controller: 'blog/articles', path: 'blog' do
      collection do
        get 'tag/:tag'                , to: 'blog/articles#tags', as: :tags
        get 'categories/:category_id' , to: 'blog/articles#category_index', as: :category
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
        get 'unsubscribe/:signature' => 'users#unsubscribe', as: 'unsubscribe'
        get 'activez-votre-compte'   => 'users#waiting_for_activation', as: 'waiting_for_activation'
        get :welcome
      end
      member do
        get   :passions
        get   :destroy_confirmation
        get   :edit_private_infos, path: 'mon-compte'
        patch :update_password
        get   :wizard
        get   :dashboard
        get   :choose_password
        post  :recommend_friends
      end
      resources :followings, only: [:index], controller: 'users/followings', path: 'favoris'
      resources :invited_users, only: [:index, :new], controller: 'users/invited_users' do
        collection do
          post :bulk_create
        end
      end
      resources :comments, only: [:index, :edit, :update], controller: 'users/comments'
      resources :messages     , controller: 'users/messages'
      resources :conversations, controller: 'users/conversations'
      resources :participation_requests, only: [:index, :show], controller: 'users/participation_requests', path: 'mes-inscriptions'
    end
    resources :emails, only: [:create]

    resources :locations, only: [:index]

    resources :statistics, only: [:create]

    resources :structures, only: [:index], path: 'etablissements', to: 'redirect#structures_index'
    resources :structures, only: [:show], path: 'etablissements', controller: 'structures' do
      member do
        get  :toggle_pure_player
        post :add_to_favorite
        post :remove_from_favorite
        get  :reviews, path: 'livre-d-or'
        get  :checkout_step_1
        get  :checkout_step_2
        get  :checkout_step_3
      end
      collection do
        post :recommendation
      end
      resources :participation_requests, only: [:create, :edit]                             , controller: 'structures/participation_requests' do
        member do
          get   :cancel_form
          get   :accept_form
          patch :accept
          patch :discuss
          patch :modify_date
          patch :cancel
        end
      end
      resources :statistics            , only: [:create]                                    , controller: 'structures/statistics'
      resources :messages              , only: [:create]                                    , controller: 'structures/messages'
      resources :places                , only: [:index]                                     , controller: 'structures/places'
      # IMPORTANT: DO NOT ADD path: 'cours', because it's already used by indexable_cards
      resources :courses               , only: [:index, :show]                              , controller: 'structures/courses'
      # Using a singular resource. (http://guides.rubyonrails.org/routing.html#singular-resources)
      resource  :community             , only: [:show]                                     , controller: 'structures/community'      , path: 'communaute' do
        resources :message_threads, only: [:show, :index, :create, :update], controller: 'structures/community/message_threads'
      end
      resources :indexable_cards       , only: [:show]                                      , controller: 'structures/indexable_cards', path: 'cours' do
        resource :favorite, only: [:create, :destroy], controller: 'structures/indexable_cards/favorite', path: 'favoris'
      end
      resources :comments              , only: [:create, :new, :show, :index, :update]      , controller: 'structures/comments'       , path: 'avis' do
        collection do
          get :create_from_email
        end
        member do
          get :add_private_message, path: 'envoyer-un-message-prive'
        end
      end
      resources :newsletters, only: [:show], controller: 'structures/newsletters'

      # Here for old 404
      resources :comments              , only: [:new]                                       , controller: 'structures/comments'   , path: 'recommendations'
      resources :comments              , only: [:new]                                       , controller: 'structures/comments'   , path: 'recommandations'
      resources :teachers              , only: [:index]                                     , controller: 'structures/teachers'
      resources :medias                , only: [:index]                                     , controller: 'structures/medias'
    end

    resources :reply_token, only: [:show]

    ########### Vertical pages ###########
    get 'cours/:id--:city_id'                                 , to: 'vertical_pages#show'          , as: :root_vertical_page_with_city
    get 'cours/:id--:city_id/:neighborhood_id'                , to: 'vertical_pages#show_with_neighborhood'  , as: :root_vertical_page_with_neighborhood
    get 'cours/:id'                                           , to: 'vertical_pages#show_root'               , as: :root_vertical_page
    get 'cours/:root_subject_id/:id'                          , to: 'vertical_pages#show'                    , as: :vertical_page
    get 'cours/:root_subject_id/:id/:city_id'                 , to: 'vertical_pages#show'          , as: :vertical_page_with_city
    get 'cours/:root_subject_id/:id/:city_id/:neighborhood_id', to: 'vertical_pages#show_with_neighborhood'  , as: :vertical_page_with_neighborhood

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
      collection do
        get :list
        get :descendants
      end
      resources :structures, only: [:index], path: 'etablissements'
      resources :places, only: [:index], path: 'etablissement', to: 'redirect#subject_place_index' # établissement without S
      resources :courses, only: [:index], path: 'cours'
    end

    resources :click_logs, only: [:create]
    resources :guides, only: [:show] do
      member do
        get :suggestions, path: 'notre-suggestion'
      end
    end

    # ------------------------------------------------------
    # ----------------------------------------- Static pages
    # ------------------------------------------------------
    # Pages
    get 'vos-resolutions-2015'               => 'home#resolutions',          as: 'home_resolutions'
    get 'vos-resolutions-2015/resultats/:id' => 'home#resolutions_results',  as: 'home_resolutions_results'

    get 'mon-compte'                    => 'home#redirect_to_account'
    get 'pourquoi-le-bon-cours',        to: 'redirect#why_coursavenue'
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
    get 'humans',                       to: 'home#humans'

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

    # Fixes / Hacks
    get 'browserconfig' => 'home#browserconfig'

    post '/mandrill-webhook' => 'mandrill_webhook#create'
    get  '/mandrill-webhook' => 'mandrill_webhook#index'
    post '/stripe_webhook', to: 'stripe_webhook#create'
    root :to => 'home#index'


    namespace :reservation, path: '' do
      resources :structures, path: 'reservation', only: [:show] do
        resources :participation_requests, only: [:create, :update, :show], path: 'inscriptions', controller: 'structures/participation_requests' do
          resources :conversations, controller: 'structures/participation_requests/conversations'
        end
        resources :gift_certificate_vouchers, only: [:index, :create, :show], path: 'bons-cadeaux', controller: 'structures/gift_certificate_vouchers'
      end
      resources :newsletters, only: [] do
        collection do
          get :unsubscribe
        end
      end
    end

    ########### Search pages ###########
    # Must be at the end not to stop other routes
    # Redirect cities that have been deleted and have slug like 'tours--57'
    get ':root_subject_id/:subject_id--:city_id--:old_city_slug', to: 'redirect#structures_index'
    get ':root_subject_id--:city_id--:old_city_slug'            , to: 'redirect#structures_index'
    # end-redirect
    get ':root_subject_id/:subject_id--:city_id'                , to: 'courses#index', as: :search_page
    get ':root_subject_id--:city_id'                            , to: 'courses#index', as: :root_search_page
    get ':city_id'                                              , to: 'courses#index', as: :root_search_page_without_subject
    ########### Search pages ###########
  end

  # ---------------------------------------------
  # -----------------------------------END OF WWW
  # ---------------------------------------------


  # ---------------------------------------------
  # ---------------------------------- RESERVATION
  # ---------------------------------------------
  constraints DomainConstraint.new do
    namespace :reservation, path: '' do
      get '/'       , to: 'structures#show'
      get 'planning' => redirect('/')
      get 'reviews' , to: 'structures#reviews' , as: :reviews, path: 'livre-d-or'
      resources :website_pages, only: [:show], path: 'pages'
    end
  end

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
  get 'cours/:id--:city_id'                        , to: 'redirect#root_vertical_pages__show_with_city'
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

  # SHOULD ALWAYS BE LAST.
  # Matches every route that is not described abouve and routes it to an error.
  if Rails.env.staging? or Rails.env.production?
    match "*path", to: "application#routing_error", via: :get
  end
end
