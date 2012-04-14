class Website::ChatPlaysController < ApplicationController
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
    send_to_next_page = :chat_plays_signup # come back here after a login
  end

end
