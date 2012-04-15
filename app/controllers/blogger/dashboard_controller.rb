class Blogger::DashboardController < ApplicationController

  before_filter :stub_blogger

  layout "dashboard"

	def index
    @sites = RylyzBloggerSite.all
	end

  private

  def stub_blogger
  end

  require 'resolv'

  def validate_hostname(hostname)
    begin
      Resolv.getaddress("www.google.com")
    rescue Resolv::ResolvError => e
      return nil
    end
  end

end
