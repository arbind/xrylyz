class WyjytController < ApplicationController
  protect_from_forgery :except => :pusher_auth

  def pusher_auth
  	puts "+++++++++++++++++++++++++++++++++++++++++++++++"
  	puts params
  	puts "+++++++++++++++++++++++++++++++++++++++++++++++"
    if should_deny_access?
      render :json => "bad_robot".to_json
    else
      enable_CORS_access
      socket_id = params[:socket_id]
      pusher_response = Pusher[params[:channel_name]].authenticate(socket_id)
      # if all is well, create a visitor session
      v = Visitor.new
      v.socket_id = socket_id
      VISITORS_SOCKETS[socket_id]=v  #make this visitor available by socket_id
      render :json => pusher_response
    end
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
