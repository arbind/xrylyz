class Blogger::DashboardController < ApplicationController
  include ApplicationHelper

  before_filter :stub_blogger

  layout "dashboard"

	def index
    @sites = @current_blogger.sites
	end

	def sites() end
	def plan()	end

  def login
    self.next_page_on_success = dashboard_url
    self.next_page_on_failure = dashboard_login_url
  end

  def logout
    self.next_page_on_success = dashboard_login_url
    redirect_to logout_url
  end

  private

  def stub_blogger
    @current_blogger = RylyzBlogger.find_or_create_by(email:'mike@test.com', invite_code:'1234')
  end

  require 'resolv'

  def validate_hostname(hostname)
    begin
      Resolv.getaddress(hostname)
    rescue Resolv::ResolvError => e
      logger.info "#{e.message}"
      nil
    end
  end

end
