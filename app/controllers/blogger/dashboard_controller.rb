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
    @site = RylyzBloggerSite.new
  end

  def add_site
    @site = current_blogger.sites.find_or_create_by(:url => params[:site][:url])

    # TODO: Move to model
    if validate_hostname(params[:site][:url])
      @site.status = "valid_url"
      notice = "Thanks for registering your site."
    else
      @site.status = "invalid_url"
      notice = "We couldn't validate your site."
    end

    if @site.update_attributes(params[:site])
      notice = "Thanks for registering your site."

      render :partial => 'registered_site', :locals => {:site => @site}
    else
      notice = "There was a problem registering your site."
      logger.info @site.errors.inspect

      @sites = []
      render :sites
    end
  end

  def delete_site
    site = current_blogger.sites.where(:url => params[:url])
    site.delete
    render :nothing => true, :status => 200
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




  def profile()
    @html_submenu_buttons = profile_submenu
  end

  def login
    # set the next page after omni auth calls 'auth/:provider/callback' or 'auth/failure'
    # flash.now[:status] = "You did it, yeaa!"
    # flash.now[:notice] = "Please go an ahead and log your self in"
    # flash.now[:error] = "That is absolutely not allowed"
    flash.now[:status] = "You are already signed in, fee free to add another provider though." if member_signed_in?
    flash.now[:error] = "You are already signed in, but you can add"
    flash.now[:notice] = "You are already signed in, but you can add"
    self.next_page_on_success = dashboard_url
    self.next_page_on_failure = dashboard_login_url
  end

  def logout
    self.next_page_on_success = dashboard_login_url
    redirect_to logout_url, :notice =>"You have been logged out!"
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
    if current_member.blogger.nil? # auto create a blogger
      blogger = RylyzBlogger.create
      current_member.blogger = blogger
      current_member.save!
    end
  end

  def dashboard_submenu
    [
      {name: 'wyjyt', href: dashboard_sites_url},
      {name: 'sites', href: dashboard_sites_url},
      {name: 'referrals', href: dashboard_referrals_url},
      {name: 'activity', href: dashboard_activity_url}
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
      {name: 'social accounts', href: dashboard_login_url },
      {name: 'credit cards', href: profile_creditcards_url}
    ]

  end

end
