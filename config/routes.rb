RylyzPlayer::Application.routes.draw do

# +++ get a logo from fiver:
# http://fiverr.com/l/logo_design_b3?order=rating&utm_source=fk_iy&utm_medium=fb50.png&utm_term=iy/small1-logo_us_male_30-38_smb-service_c_fb50.png_ld3&utm_content=l-b3&utm_campaign=bs_us


  root :controller => :root, :action => :index

  # Public Website Routes (no current_member required)
  scope :module => :website, :controller=> "chat_plays" do #The ChatPlays websites
    get "index",     :as => :home_page
    get "pricing",    :as => :pricing
    get "profiting",  :as => :profiting
    get "installing", :as => :installing
    get "contact_us", :as => :contact_us
    get "sign_up",    :as => :sign_up
  end

  # Dashboard Routes for bloggers
  scope :module => :blogger, :controller => "dashboard" do
    get 'login',            :as => :dashboard_login
    get 'logout',           :as => :dashboard_logout
    get 'signup',           :as => :dashboard_signup
    get 'this_is_not_me',   :as => :dashboard_this_is_not_me
    get 'confirm_signup/:share_key', :to => 'dashboard#confirm_signup'

    # +++ add dashboard resources for sites, keys, referrals, analytics, etc. (must be an authenticated blogger)
    get 'dashboard',        :as => :dashboard,            :to => 'dashboard#index'
    get 'websites',            :as => :dashboard_websites
    post 'register_website',        :as => :dashboard_register_website
    post 'unregister_website',     :as => :dashboard_unregister_website
    get 'visitors',        :as => :dashboard_visitors

    get 'dollar',           :as => :dashboard_dollar
    get 'profit_sharing',        :as => :dashboard_profit_sharing
    get 'referrals',        :as => :dashboard_referrals

    get 'me',                 :as => :dashboard_me
    get 'social_accounts',    :as => :dashboard_social_accounts
    get 'subscription_plans', :as => :dashboard_subscription_plans
    get 'creditcards',        :as => :profile_creditcards
    post 'add_creditcard',    :as => :dashboard_add_creditcard

post 'test_purchase', :as => :dashboard_test_purchase
  end

  # Public Showcase
  scope '/showcase', :module => :blogger, :controller => "showcase" do
    get 'chat',     :as => :showcase_chat
    get 'games',    :as => :showcase_games
    get 'blog',     :as => :showcase_blog
    get 'scratch',  :as => :showcase_scratch
  end

  # Authentication for Humans
  scope '/auth', :module => :member, :controller => 'auth'  do
    get 'login',                  :as => :login
    get 'logout',                 :as => :logout
    match '/:provider/callback',  :to => 'auth#omniauth_login_callback',    :via => [:get, :post] # omni auth callback
    match '/failure',             :to => 'auth#omniauth_failure_callback',  :via => [:get, :post] # omni auth callback
    delete 'destroy_presence',    :as => :destroy_presence # remove a member's social presence
  end

  scope '/purchase', :module => :member do
    get '/coins',               :to => 'purchase#coins',  :as => :purchase_coins
  end

  namespace :wyjyt do
    post '/auth/pusher_access' # Grant access to wygyts using pusher

    # Wyjyt Intents (launched in a new window)
    get '/intent/wyjyt',    :as => :intent_to_wyjyt
    get '/intent/login',    :as => :intent_to_login
    get '/intent/logout',   :as => :intent_to_logout
    get '/intent/share',    :as => :intent_to_share
    get '/intent/invite',   :as => :intent_to_invite
    get '/intent/purchase', :as => :intent_to_purchase
  end

  scope "/sudo", :module => :sudo, :controller => 'control_panel' do
    get '',        :to => 'control_panel#index', :as => :sudo_index
    get 'index'
    get 'new_bloggers',        :as => :sudo_new_bloggers
    get 'signups',        :as => :sudo_signups
    post 'load_signups',  :as => :sudo_load_signups
    get 'api',        :as => :sudo_api
    # +++ add super user functionality - make sure to include super secure authentication
  end

end
