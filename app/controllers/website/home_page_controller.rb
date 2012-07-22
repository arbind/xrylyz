class Website::HomePageController < ApplicationController
  include ApplicationHelper
  before_filter :redirect_wygyt_to_www # make sure redirect before filters run first

  layout "home_page", :except => :signup

  def index
  end

  def login
    redirect_to dashboard_login_path
  end

  def logout
    logout_current_member
    redirect_to root_path
  end

  def signup
    render layout: "plain"
  end


  def pricing
  end

  def profiting
  end

  def installation
  end

  def privacy_policy
  end

  def contact_us
  end

end
