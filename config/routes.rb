RylyzPlayer::Application.routes.draw do

  scope '/website' do
    scope '/chat_plays', :controller=> "Website::ChatPlays" do #The ChatPlays websites
      get "index",      :as => :chat_plays_index
      get "pricing",    :as => :chat_plays_pricing
      get "profiting",  :as => :chat_plays_profiting
      get "installing", :as => :chat_plays_installing
      get "contact_us", :as => :chat_plays_contact_us
      get "sign_up",    :as => :chat_plays_sign_up
    end
  end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with 'root'
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  namespace :blogger do 
    # Dashboard (blogger must be authenticated in to view these)
    get '/dashboard',       :to => 'dashboard#index', :as => :blogger_dashboard
    get '/dashboard/index'

    # +++ add dashboard resources for sites, keys, referrals, analytics, etc. (must be an authenticated blogger)

    # blogger intents (must be an authenticated blogger)
    get '/intent/login',    :as => :blogger_intent_to_login
    get '/intent/share',    :as => :blogger_intent_to_share
    get '/intent/invite',   :as => :blogger_intent_to_invite

    # showcase examples
    get '/showcase/blog'
    get '/showcase/games'
    get '/showcase/scratch'

  end


  scope '/auth', :module => :member  do
    # authentication for humans
    get '/login',               :to => 'auth#login',  :as => :login
    get '/logout',              :to => 'auth#logout', :as => :logout
    delete '/destroy_presence', :to => 'auth#destroy_presence', :as => :destroy_presence # delete social presence from account

    # omni-auth callback for successfull login 
    match '/:provider/callback',  :to => 'auth#omniauth_login_callback',  :via => [:get, :post]
    # omni-auth callback for failed login: User Canceled, or returned to app or entered invalid credentials
    match '/failure',             :to => 'auth#omniauth_failure_callback',  :via => [:get, :post]
  end


  scope '/purchase', :module => :member  do
    get '/coins',               :to => 'purchase#coins',  :as => :purchase_coins
  end


  namespace :payment do
    post 'stripe/authorize_charge'
  end

  namespace :sudo do
    # +++ add super user functionality - make sure to include super secure authentication

  end

  namespace :wyjyt do

    # Grant access to wygyts using pusher
    post '/auth/pusher_access'

    # wyjyt intents    
    get '/intent/login',    :as => :wyjyt_intent_to_login
    get '/intent/share',    :as => :wyjyt_intent_to_share
    get '/intent/invite',   :as => :wyjyt_intent_to_invite
    get '/intent/purchase', :as => :wyjyt_intent_to_purchase
  end

end
