class Blogger::DashboardController < ApplicationController

  before_filter :stub_blogger

  layout "dashboard"

	def index
    @sites = @current_blogger.sites
	end

	def login()	end
	def sites() end
	def plan()	end

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
