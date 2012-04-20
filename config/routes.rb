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
    # +++ add dashboard resources for sites, keys, referrals, analytics, etc. (must be an authenticated blogger)
    get 'dashboard',        :as => :dashboard,            :to => 'dashboard#index'
    get 'sites',            :as => :dashboard_sites
    post 'add_site',         :as => :dashboard_add_site
    get 'referrals',        :as => :dashboard_referrals
    get 'analytics',        :as => :dashboard_analytics
    get 'billing',          :as => :dashboard_billing
    post 'add_credit_card', :as => :dashboard_add_credit_card
post 'test_purchase', :as => :dashboard_test_purchase
    get 'plan',             :as => :dashboard_plan
    get 'profile',          :as => :dashboard_profile
    get 'login',            :as => :dashboard_login
    get 'logout',           :as => :dashboard_logout
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

  namespace :sudo do
    get 'control_panel/signups',        :as => :sudo_signups
    post 'control_panel/load_signups',  :as => :sudo_load_signups
    # +++ add super user functionality - make sure to include super secure authentication
  end

end
