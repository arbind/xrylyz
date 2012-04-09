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
  end

  def omniauth_login_callback
    # if a current_member is signed in already, add this provider as another presence to the current_member
    # if a current_member is not signed in but this presence has signed in before, just sign them in again
    # if a current_member is not signed in and this is a new presence, create a new member and sign them in for the first time
    omni_auth = request.env["omniauth.auth"]
    begin
      #lookup existing presence from this provider (repeat sign in), or create a new one (fist sign in)
      presence = RylyzMemberPresence.materialize_from_omni_auth(omni_auth)

      if current_member # already signed in, just add this provider presence
          current_member.add_social_presence presence     
      else # not signed in
        if presence.member # this presence has signed in from this provider before, just sign them in again
          current_member = presence.member
        else # this presence is signing in for the first time from this provider
          # create a new member (or find one matching the same email as this presence)
          current_member = RylyzMember.materialize(presence.email, presence.nickname, presence.is_verified)
          current_member.add_social_presence presence unless current_member.nil? # add this presence to the new member
        end
      end
      render :text => current_member.email
    rescue Exception => e 
      redirect_to_login_page
      puts e.message
      s = "exception: #{e.message}<br>"
      s << e.backtrace.join("<br>")
      render :text => s
    ensure
      redirect_to_login_page if current_member.nil?
    end
  end

  def omniauth_login_failure_callback
    #User may have canceled
    # e.g: https://rylyz-local.com/auth/failure?message=invalid_credentials
    # log this cancelation
    # send game event to wid if not blogger member
    # take them back to sign in page they came from 
    redirect_to_login_page
  end

  def omniauth_logout
    current_member = nil
  end

  def redirect_to_login_page
    # redirect_to :blogger_login
    # redirect_to :login
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
