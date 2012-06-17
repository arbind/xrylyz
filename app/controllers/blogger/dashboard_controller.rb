class Blogger::DashboardController < ApplicationController
  include ApplicationHelper
  before_filter :require_member_to_be_signed_in,  :except => [:login, :logout]
  before_filter :require_blogger_to_be_signed_in, :except => [:login, :logout, :index]
  before_filter :register_blogger, :only => [:index]

  layout "dashboard"

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
    domain = params[:domain]
    site = current_blogger.sites.where(:domain => domain)
    if site
      site.delete
      warn = "#{domain} deleted!"
    else
      error = "#{domain} cannot be deleted."
    end

    redirect_to :dashboard_sites, :flash => {:warn => warn, :error => error}
  end

  def referrals

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

  def login
    self.current_member = nil #logout current_member immediately if a share key is present

    share_key = params[:share_key]
    session[:share_key] = share_key unless share_key.nil?

    self.next_page_on_success = dashboard_url
    self.next_page_on_failure = dashboard_login_url
  end

  def logout
    self.current_member = nil #logout current_member immediately if a share key is present
    redirect_to dashboard_login_url, :notice =>"You have been logged out!"

    # self.next_page_on_success = dashboard_login_url
    # redirect_to logout_url, :notice =>"You have been logged out!"
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
    if current_member.blogger.nil?
      share_key = session[:share_key]
      blogger = RylyzBlogger.where(:share_key => share_key).first
      blogger ||= RylyzBlogger.create
      current_member.blogger = blogger
      current_member.save!
    end
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
