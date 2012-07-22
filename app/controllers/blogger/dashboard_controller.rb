class Blogger::DashboardController < ApplicationController
  include ApplicationHelper
  before_filter :require_member_to_be_signed_in,  :except => [ :activate_me, :this_is_not_me, :login, :logout, :signup ]
  before_filter :require_blogger_to_be_signed_in, :except => [ :index, :activate_me, :this_is_not_me, :login, :logout, :signup ]
  before_filter :check_for_blogger, :only => [ :index ]
  before_filter :in_dashboard_website
  before_filter :check_for_dot_com_domain

  layout "dashboard", :except => [:signup]

  #
  #
  #
  def activate_me
    logout_current_member
    share_key = params[:share_key]
    redirect_to :home_page, :notice=>'Please signup to activate an account!' and return if share_key.empty?

    @activating_blogger = RylyzBlogger.where(:share_key => share_key).first
    redirect_to :home_page, :notice=>'Please signup to activate an account!' and return if @activating_blogger.nil?

puts "o id #{@activating_blogger.id}"
    session[:activating_blogger_id] = @activating_blogger.id
puts "o ss #{session[:activating_blogger_id]}"
    redirect_to :dashboard_login
  end

  #
  #
  #
  def this_is_not_me
    session[:activating_blogger_id] = nil
    redirect_to :dashboard_login
  end

  #
  #
  #
  def login
    activating_blogger_id = session[:activating_blogger_id]   # see if blogger is activating their account

    logout_current_member # logout anyone comming to this page

    if activating_blogger_id
      session[:activating_blogger_id] = activating_blogger_id # keep them in session in order to bind them after authentication
      @activating_blogger = RylyzBlogger.find(activating_blogger_id)
    end

    self.next_page_on_success = dashboard_url
    self.next_page_on_failure = dashboard_login_url
  end

  # Logout
  #
  #
  def logout
    logout_current_member
    redirect_to :dashboard_login, :notice => "You have been logged out!"
  end

	def index
    @html_submenu_buttons =  dashboard_submenu
    @sites = current_blogger.sites || []
    @plan = current_blogger.plan
	end

  def websites
    @html_submenu_buttons =  dashboard_submenu
    @sites = current_blogger.sites || []
  end

  def website
    id = params[:id]
    @site = current_blogger.sites.find(id)
    @site.site_key ||= "nokey"
    @html_submenu_buttons =  dashboard_submenu
  end

  def register_website
    d =  params[:site][:domain]
    @scheme, @domain = RylyzBloggerSite.uri_components (d)
    if @scheme and @domain
      @site = current_blogger.sites.find_or_create_by(:scheme => @scheme, :domain => @domain)
      if @site
        status = "Thanks for registering #{@domain}."
        notice = "Click on the code to copy, then paste it into your pages!"
        redirect_to dashboard_website_path(@site), :flash => {:notice => notice, :status => status}
      end
    end

    if not @site
      error = "We couldn't validate #{@domain}. It was not registered."
      redirect_to :dashboard_websites, :flash => {:error => error}
    end

  end

  def unregister_website
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

    redirect_to :dashboard_websites, :flash => {:warn => warn, :error => error}
  end

  def visitors
    @html_submenu_buttons =  dashboard_submenu
  end


	def dollar()
    @plan = current_blogger.plan
    @html_submenu_buttons = dollar_submenu
  end

  def referrals
    @html_submenu_buttons = dollar_submenu
  end


  def me
    @html_submenu_buttons = profile_submenu
  end

  def social_accounts
    @html_submenu_buttons = profile_submenu

  end

  def subscription_plans
    @plan = current_blogger.plan
    @html_submenu_buttons = profile_submenu
  end

  def creditcards()
    @html_submenu_buttons = profile_submenu
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

  private

  def in_dashboard_website
    session[:in_website] = :dashboard
  end

  def check_for_blogger

    if current_member.blogger.nil? # 1st login, see if they are confirming their account

      activating_blogger_id = session[:activating_blogger_id]
      @activating_blogger = RylyzBlogger.find(activating_blogger_id) if activating_blogger_id

      # redirect to signup page if there was no confirmation
      if @activating_blogger.nil?
        logout_current_member
        redirect_to :signup, :notice => "Please signup and check for your activation email!" and return
      end

      # blogger has logged in for the first time and confirmed their account
      current_member.blogger = @activating_blogger
      current_member.save!
      flash.now[:notice] = "Thanks for confirming your account! You can now register your website(s)!"
    end
    clear_next_page_from_session # clear out the next_page_on_success/failure vars from session
    session[:activating_blogger_id] = nil # clear out any signup confirmation var from session
  end

  def dashboard_submenu
    [
      {name: 'overview',        href: dashboard_url},
      {name: 'websites',        href: dashboard_websites_url},
      {name: 'visitors',        href: dashboard_visitors_url},
    ]
  end

  def dollar_submenu
    [
      {name: 'profit sharing',  href: dashboard_dollar_url},
      {name: 'referrals',       href: dashboard_referrals_url},
    ]
  end

  def profile_submenu
    [
      {name: 'profile',         href: dashboard_me_url},
      {name: 'plan',            href: dashboard_subscription_plans_url },
      {name: 'social', href: dashboard_social_accounts_url },
      {name: 'credit cards',    href: profile_creditcards_url}
    ]
  end

end
