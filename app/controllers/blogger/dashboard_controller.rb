class Blogger::DashboardController < ApplicationController
  include ApplicationHelper
  before_filter :require_member_to_be_signed_in,  :except => [:login, :logout]
  before_filter :require_blogger_to_be_signed_in, :except => [:login, :logout, :index]
  before_filter :register_blogger, :only => [:index]

  layout "dashboard"

	def index
    @sites = current_blogger.sites || []
	end

	def sites
    @sites = current_blogger.sites || []
  end

  def add_site
    site = current_blogger.sites.find_or_create_by(:url => params[:site][:url])

    if validate_hostname(params[:site][:url])
      site.status = "valid_url"
      notice = "Thanks for registering your site."
    else
      site.status = "invalid_url"
      notice = "We couldn't validate your site."
    end

    site.update_attributes(params[:site])

    redirect_to :action => :sites, :notice => notice
  end

	def plan()	end
  def billing()  end
  def profile()  end

  def add_credit_card
    current_member.save_stripe_credit_card(params[:stripeToken])
    redirect_to :dashboard_billing
  end

  def test_purchase
    amount = params[:amount]
    item = params[:item]
    current_member.credit_cards.all.first.charge(amount);
    redirect_to :dashboard_billing
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

end
