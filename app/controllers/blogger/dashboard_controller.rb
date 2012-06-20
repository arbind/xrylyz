class Blogger::DashboardController < ApplicationController
  include ApplicationHelper
  before_filter :require_member_to_be_signed_in,  :except =>         [ :confirm_signup, :this_is_not_me, :login, :logout, :signup ]
  before_filter :require_blogger_to_be_signed_in, :except => [ :index, :confirm_signup, :this_is_not_me, :login, :logout, :signup ]
  before_filter :register_blogger, :only => [ :index ]

  layout "dashboard"

  #
  # 
  #
  def confirm_signup
    share_key = params[:share_key]
    @signup_confirmation_blogger = RylyzBlogger.where(:share_key => share_key).first
    session[:signup_confirmation_blogger_oid] = @signup_confirmation_blogger.id if not @signup_confirmation_blogger.nil?
    redirect_to :dashboard_login
  end

  #
  # 
  #
  def this_is_not_me
    session[:signup_confirmation_blogger_oid] = nil
    redirect_to :dashboard_login
  end


  #
  #
  #
  def dashboard_signup

  end


  #
  # 
  #
  def login
    self.current_member = nil #logout current_member immediately

    signup_confirmation_blogger_oid = session[:signup_confirmation_blogger_oid] # see if blogger is confirming their signup
    @signup_confirmation_blogger = RylyzBlogger.find(signup_confirmation_blogger_oid) if signup_confirmation_blogger_oid

    self.next_page_on_success = dashboard_url
    self.next_page_on_failure = dashboard_login_url
  end

  # Logout
  # 
  #
  def logout
    self.current_member = nil #logout current_member immediately if a share key is present
    session[:signup_confirmation_blogger_oid] = nil

    redirect_to :dashboard_login, :notice =>"You have been logged out!"
  end


	def index
    @html_submenu_buttons =  dashboard_submenu
    @sites = current_blogger.sites || []
	end

  def sites
    @html_submenu_buttons =  dashboard_submenu
    @sites = current_blogger.sites || []
  end

  def add_site
    domain =  params[:site][:domain]
    if validate_hostname(domain)
      @site = current_blogger.sites.find_or_create_by(:domain => domain)
      notice = "Thanks for registering #{domain}."
    else
      error = "We couldn't validate #{domain}. It was not registered."
    end

    redirect_to :dashboard_sites, :flash => {:notice => notice, :error => error}
  end

  def delete_site
    logger.info params
    oid = params[:oid]
    site = current_blogger.sites.find(oid)
    if site
      url = site.url
      site.delete
      warn = "#{url} deleted!"
    else
      error = "site id #{oid} cannot be deleted."
    end

    redirect_to :dashboard_sites, :flash => {:warn => warn, :error => error}
  end

  def referrals
    @html_submenu_buttons =  dashboard_submenu
  end

  def activity
    @html_submenu_buttons =  dashboard_submenu
  end

	def dollar()
    @html_submenu_buttons = dollar_submenu
  end

  def revenues()
    @html_submenu_buttons = dollar_submenu
  end

  def costs()
    @html_submenu_buttons = dollar_submenu
  end

  def creditcards()
    @html_submenu_buttons = dollar_submenu
  end

  def add_creditcard
    current_member.save_stripe_credit_card(params[:stripeToken])
    redirect_to :dashboard_billing
  end

  def test_purchase
    amount = params[:amount]
    item = params[:item]
    current_member.credit_cards.all.first.charge(amount);
    redirect_to :dashboard_billing
  end

  def social_accounts 
    
  end

  def profile()
    @html_submenu_buttons = profile_submenu
  end

  private

  require 'resolv'

  def validate_hostname(hostname)
    begin
      Resolv.getaddress(hostname)
    rescue Resolv::ResolvError => e
      logger.info "#{e.message}"
      nil
    end
  end

  def register_blogger

    if current_member.blogger.nil? # 1st login, see if they are confirming their account

      signup_confirmation_blogger_oid = session[:signup_confirmation_blogger_oid]
      @signup_confirmation_blogger = RylyzBlogger.find(signup_confirmation_blogger_oid) if signup_confirmation_blogger_oid

      # redirect to signup page if there was no confirmation
      redirect_to :dashboard_signup, :notice => "Please signup first. We'll send you a confirmation email so you can login!" if @signup_confirmation_blogger.nil?

      # blogger has logged in for the first time and confirmed their account
      current_member.blogger = @signup_confirmation_blogger
      current_member.save!
      flash.now[:notice] = "Thanks for confirming your account! You can now register your websites!"
    end

    session[:signup_confirmation_blogger_oid] = nil
  end

  def dashboard_submenu
    [
      {name: 'overview', href: dashboard_url},
      {name: 'websites', href: dashboard_sites_url},
    ]
  end

  def dollar_submenu
    [
      {name: 'revenues', href: dollar_revenues_url},
      {name: 'costs', href: dollar_costs_url}
    ]
  end

  def profile_submenu
    [
      {name: 'social accounts', href: dashboard_social_accounts_url },
      {name: 'referrals', href: dashboard_referrals_url},
      {name: 'activity', href: dashboard_activity_url},
      {name: 'credit cards', href: profile_creditcards_url}
    ]
  end

end
