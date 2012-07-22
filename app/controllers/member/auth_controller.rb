class Member::AuthController < ApplicationController
  include ApplicationHelper

  def login
    # Before showing this login endpoint:
    #   be sure to set next_page_on_success, next_page_on_failure and layout_on_render
    render :layout => layout_on_render!
  end

  def logout
    logout_current_member
    next_page = next_page_on_success
    redirect_to next_page
  end

  # method=DELETE
  def destroy_presence
    # +++ destroy member presence
    #   @authentication = current_user.authentications.find(params[:id])
    #   @authentication.destroy
    #   flash[:notice] = t(:successfully_destroyed_authentication)
    #   redirect_to authentications_url
  end

  def omniauth_login_callback
    # +++ up the sign_in_count and last_signed_in_at times for both the member and the presence
    # if a member has signed in with this social presence before, just sign them in again (switch user if necessary)
    # otherwise
    #   if a current_member is signed in already, add this provider as another presence to the current_member
    #     double check that this provider is not already in the list as another uid, if so, create a new member and switch user
    #   if a current_member is not signed in and this is a new presence, create a new member and sign them in for the first time
    next_page = nil

    # logout clears activating_blogger from the session, so capture it in case logout is invoked (or self.current_member = nil)
    activating_blogger_id = session[:activating_blogger_id]
# puts "auth 1 - activating_blogger_id"
    begin
# puts "auth 2"
      #lookup existing presence from this provider (repeat sign in), or create a new one (fist sign in)
      presence = RylyzMemberPresence.materialize_from_omni_auth(omniauth_hash)
      presence.mark_sign_in
# puts "auth #{presence.email}"
      if presence.signed_in_before? # this presence has signed in from this provider before, just sign them in again
# puts "auth 3 - have signed in before"
        if member_signed_in? # member already signed in
# puts "auth 4 - member signed in: #{current_member.email}"
          unless self.current_member.id == presence.member.id
# puts "auth 5 switch user from #{current_member.email} to #{presence.member.email}"
            #swich user: already signed in as another member
            # +++ bump up sign_in_count for current_member and set last_signed_in_at
            self.current_member = presence.member
          end
# puts "auth 6"
        else # not signed in
# puts "auth 7 - not signed in, siging in as #{presence.member.email}"
          self.current_member = presence.member
        end
# puts "auth 8"
      else # signing in with this social presence for the first time from this provider
# puts "auth 9 - singing in for first time"
        if member_signed_in? and self.current_member.social_presences.where({:provider => presence.provider}).empty? # <-- need to test why this doesnt work
# puts "auth 10 already signed in: adding this as another social presence"
            # member already signed in, just add to this members list of social presences
            self.current_member.add_social_presence presence
        else # not signed in
# puts "auth 11 - not signed in: activating member: #{activating_blogger_id}"
          # see if there is signup confirmation
          @activating_blogger = RylyzBlogger.find(activating_blogger_id) if activating_blogger_id
# puts "@activating_blogger  = #{@activating_blogger}"          
# puts "@activating_blogger.member  = #{@activating_blogger.member}" if not @activating_blogger.nil?

# puts "1current_member  = #{current_member}"          
          # see if the blogger has confirmed before using a different provider (just add this as new provider to same member)
          self.current_member = @activating_blogger.member if not @activating_blogger.nil?
# puts "2current_member  = #{current_member}"          

          # if create a new member (or find one matching the same email as this presence)
          self.current_member ||= RylyzMember.materialize(presence.email, presence.nickname, presence.is_verified)
# puts "3current_member  = #{current_member}:#{current_member.nickname}"          
          self.current_member.add_social_presence presence unless current_member.nil? # add this presence to the new member
# puts "4current_member  = #{current_member}"          
        end
# puts "auth 12"
      end
# puts "auth 13"
      #next_page = next_page_on_failure! if self.current_member.nil?
    rescue Exception => e
# puts "auth 14 login exception!"
      logger.error "Oauth Error #{e.message}"
      s = "exception: #{e.message}<br>"
      s << e.backtrace.join("<br>")
      next_page = next_page_on_failure
      error = "Login failed. #{e.message}"
    ensure
# puts "auth 15 - ensure"
    session[:activating_blogger_id] = activating_blogger_id if activating_blogger_id # restore the session

      next_page ||= next_page_on_success

      if next_page.nil?
# puts "auth 16 - redirect set to dashboard"
        redirect_to dashboard_login_path and return if :wygyt != session[:in_website]
      end

# puts "auth 17 redirecting to: #{next_page}"
      redirect_to next_page, :flash => {:notice => notice, :error => error}
    end
  end

  def omniauth_failure_callback
    #User may have canceled
    # e.g: https://rylyz-local.com/auth/failure?message=invalid_credentials
    # +++ log this cancelation
    # +++ send game event to wid if not blogger member
    redirect_to next_page_on_failure
  end

  private

  def omniauth_hash
    request.env['omniauth.auth']
  end

end
