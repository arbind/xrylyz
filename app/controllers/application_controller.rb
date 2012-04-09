class ApplicationController < ActionController::Base
  helper_method :current_member, :signed_in?

 protected

  def current_member
  	member_id = session[:member_id]
    @current_member ||= RylyzMember.find(member_id) unless member_id.nil?
  end

  def current_member=(member)
  	member_id = nil
  	member_id = member.id.to_s unless member.nil?

    @current_member = member
    session[:member_id] = member_id
  end

  def signed_in?
    !!current_member
  end

  def current_member_presences  	
		@member_presences ||= current_member.member_presences if current_member
	end
end
