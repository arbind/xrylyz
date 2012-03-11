class WyjytController < ApplicationController
  protect_from_forgery :except => :pusher_auth
  before_filter :enable_CORS_access, :only => :pusher_auth

  def pusher_auth
  	puts "+++++++++++++++++++++++++++++++++++++++++++++++"
  	puts params
  	puts "+++++++++++++++++++++++++++++++++++++++++++++++"
    pusher_response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
    render :json => pusher_response
  end

  private

  def should_deny_access?
  	#lookup request referrer to see if website domain is registered for rylyz
  	false
  end

  def enable_CORS_access
    return if should_deny_access?
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Allow-Methods']     = 'GET, POST, OPTIONS'
    headers['Access-Control-Allow-Headers']     = 'Content-Type, *'
    headers['Access-Control-Allow-Origin']      = '*'
  end

end
