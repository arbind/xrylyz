RylyzPlayer::Application.routes.draw do
  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  namespace :blogger do
    #Dashboard (blogger must be logged in to view these)
    get '/dashboard',       :to => 'dashboard#index', :as => :blogger_dashboard
    get '/dashboard/index'

    #+++ add resources for a blogger's sites, keys, referrals, analytics, etc.

    #blogger intents
    get '/intent/login',    :as => :blogger_intent_to_login
    get '/intent/share',    :as => :blogger_intent_to_share
    get '/intent/invite',   :as => :blogger_intent_to_invite

    # showcase examples
    get "/showcase/blog"
    get "/showcase/games"
    get "/showcase/scratch"

  end


  scope '/auth', :module => :member  do
    #human authentication
    get '/login',               :to => 'auth#login',  :as => :login
    get '/logout',              :to => 'auth#logout', :as => :logout
    delete '/destroy_presence', :to => 'auth#destroy_presence', :as => :destroy_presence # delete social presence from account

    # omni-auth callback for successfull login 
    match '/:provider/callback',  :to => 'auth#omniauth_login_callback',  :via => [:get, :post]
     # omni-auth callback for failed login: User Canceled, or returned to app or entered invalid credentials
    match '/failure',             :to => 'auth#omniauth_failure_callback',  :via => [:get, :post]
  end

  namespace :sudo do
    # +++
  end

  namespace :wyjyt do
    #pusher authentication: post "auth/pusher_auth"
    match "/auth/pusher",      :via => [:post]

    #wyjyt intents    
    match '/intent/login',    :as => :wyjyt_intent_to_login
    match '/intent/purchase', :as => :wyjyt_intent_to_purchase
    match '/intent/share',    :as => :wyjyt_intent_to_share
    match '/intent/invite',   :as => :wyjyt_intent_to_invite
  end

end
