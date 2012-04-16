class Wyjyt::IntentController < ApplicationController
  layout "wyjyt"
  include ApplicationHelper

  def wyjyt
  end

  def login
    socket_id = params[:timestamp] # socket_id is hidden as timestamp parameter

    self.next_page_on_success = [:wyjyt, :intent_to_wyjyt]
    self.next_page_on_failure = [:wyjyt, :intent_to_login]

  end

  def purchase
    socket_id = params[:timestamp] # socket_id is hidden as timestamp
    send_to_next_page = :member_purchase
  end


  def share
    socket_id = params[:timestamp] # socket_id is hidden as timestamp
    send_to_next_page = :login
    redirect_to :login
  end

  def invite
    socket_id = params[:timestamp] # socket_id is hidden as timestamp
    send_to_next_page = :login
    redirect_to :member_login
  end

end
