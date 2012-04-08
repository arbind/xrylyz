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
    # @authentications = current_user.authentications if current_user
  end

  def omniauth_login_callback
   # omniauth = request.env["omniauth.auth"]  
   #  authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
   #  if authentication  
   #    # Just sign in an existing user with omniauth
   #    # The user have already used this external account
   #    flash[:notice] = t(:signed_in)
   #    sign_in_and_redirect(:user, authentication.user)
   #  elsif current_user
   #    # Add authentication to signed in user
   #    # User is logged in
   #    current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
   #    flash[:notice] = t(:success)
   #    redirect_to authentications_url
   #  elsif omniauth['provider'] != 'twitter' && omniauth['provider'] != 'linked_in' && user = create_new_omniauth_user(omniauth)
   #    user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
   #    # Create a new User through omniauth
   #    # Register the new user + create new authentication
   #    flash[:notice] = t(:welcome)
   #    sign_in_and_redirect(:user, user)
   #  elsif (omniauth['provider'] == 'twitter' || omniauth['provider'] == 'linked_in') && 
   #    omniauth['uid'] && (omniauth['user_info']['name'] || omniauth['user_info']['nickname'] || 
   #    (omniauth['user_info']['first_name'] && omniauth['user_info']['last_name']))
   #    session[:omniauth] = omniauth.except('extra');
   #    redirect_to(:controller => 'registrations', :action => 'email')
   #  else
   #    # New user data not valid, try again
   #    flash[:alert] = t(:fail)
   #    redirect_to new_user_registration_url
   #  end

        # @user = User.find_or_create_from_auth_hash(omniauth_hash)
    # self.current_user = @user
    # redirect_to '/'
    s = "You have Singed in with your #{params[:provider]} ID!<hr>"
    s << "<![CDATA["
    s << "\n"
    s << omniauth_hash.to_yaml.to_yaml
    s << "\n"
    s << "]]>"
    render :text => s
  end

  def omniauth_login_failure_callback
    # twitter callback for "Cancel, and return to app"
    # e.g: https://ondeck.local/auth/failure?message=invalid_credentials
    # log this cancelation, send game event to wid 
    # redirect_to :login
    s = "<![CDATA["
    s << params.to_yaml
    s << "]]>"
    render :text => s
  end

  def omniauth_logout
  end


  # def destroy
  #   @authentication = current_user.authentications.find(params[:id])
  #   @authentication.destroy
  #   flash[:notice] = t(:successfully_destroyed_authentication)
  #   redirect_to authentications_url
  # end
  
  # def create_new_omniauth_user(omniauth)
  #   user = User.new
  #   user.apply_omniauth(omniauth, true)
  #   if user.save
  #     user
  #   else
  #     nil
  #   end
  # end


  private

  def pusher_should_deny_access?
  	#lookup request referrer to see if website domain is registered for rylyz
  	false
  end

  def enable_CORS_access
    return if pusher_should_deny_access?
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Allow-Methods']     = 'GET, POST, OPTIONS'
    headers['Access-Control-Allow-Headers']     = 'Content-Type, *'
    headers['Access-Control-Allow-Origin']      = '*'
  end

  def omniauth_hash
    request.env['omniauth.auth']
  end

end
