class WyjytController < ApplicationController
  protect_from_forgery :except => :pusher_auth

  def pusher_auth
  	puts "+++++++++++++++++++++++++++++++++++++++++++++++"
  	puts params
  	puts "+++++++++++++++++++++++++++++++++++++++++++++++"
    if pusher_should_deny_access?
      render :json => "bad_robot".to_json
    else
      enable_CORS_access
      socket_id = params[:socket_id]
      pusher_response = Pusher[params[:channel_name]].authenticate(socket_id)
      # if all is well, create a visitor session
      v = Visitor.new
      v.socket_id = socket_id
      VISITOR_SOCKETS[socket_id]=v  #make this visitor available by socket_id
      render :json => pusher_response
    end
  end

  def omniauth_login
    s = "<hr>"
    s << "<a href='/auth/twitter'>twitter</a>"
    s << "<hr>"
    s << "<a href='/auth/facebook'>facebook</a>" 
    s << "<hr>"
    s << "<a href='/auth/google_oauth2'>Google</a>"
    s << "<hr>"
    render :text => s.html_safe
  end

  def omniauth_login_callback
    # @user = User.find_or_create_from_auth_hash(omniauth_hash)
    # self.current_user = @user
    # redirect_to '/'
    s = "<![CDATA["
    s << "\n"
    s << omniauth_hash.to_yaml.to_yaml
    s << "\n"
    s << "]]>"
    render :text => s
  end

  def omniauth_login_failure_callback
    # twitter callback for "Cancel, and return to app"
    # e.g: http://ondeck.local/auth/failure?message=invalid_credentials
    # log this cancelation, send game event to wid 
    # redirect_to :login
    s = "<![CDATA["
    s << params.to_yaml
    s << "]]>"
    render :text => s
  end

  def omniauth_logout
  end

  private

  def pusher_should_deny_access?
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

  def omniauth_hash
    request.env['omniauth.auth']
  end

end
