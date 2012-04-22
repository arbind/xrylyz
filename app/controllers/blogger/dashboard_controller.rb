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
  end

  def add_site

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
    flash.now[:status] = "You are already signed in, but you can add another provider:" if member_signed_in?
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
