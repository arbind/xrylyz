class Website::ChatPlaysController < ApplicationController
  include ApplicationHelper
  layout "chat_plays"
  
  def index
  end

  def pricing
  end

  def profiting
  end

  def installation
  end

  def contact_us
  end

  def sign_up
    self.next_page_on_success = :dashboard
    self.next_page_on_failure = :signup
    redirect_to dashboard_url if not current_blogger.nil?
  end

end
