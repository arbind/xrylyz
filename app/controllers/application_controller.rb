class ApplicationController < ActionController::Base
  helper_method :current_member, :signed_in?

 protected

  def current_member
  	member_id = session[:member_id]
    if member_id
    	@current_member ||= RylyzMember.find(member_id) 
    end
		@current_member
  end

  def current_member=(member)
  	member_id = nil
  	member_id = member.id.to_s unless member.nil?

    @current_member = member
    session[:member_id] = member_id
    @current_member.mark_sign_in unless @current_member.nil?
  end

  def signed_in?
    !!current_member
  end

  def current_member_presences  	
		@member_presences ||= current_member.member_presences if current_member
	end
end
