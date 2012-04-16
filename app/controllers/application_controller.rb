class ApplicationController < ActionController::Base
  helper_method :current_member, :member_signed_in?, :social_presences
  helper_method :current_blogger, :member_signed_in?
  helper_method :current_super_user, :super_user_signed_in?

 protected


  def require_member_to_be_signed_in
    redirect_to :dashboard_login if not member_signed_in?
  end
  def require_blogger_to_be_signed_in
    redirect_to :dashboard_logout if not blogger_signed_in?
  end
  def require_super_user_to_be_signed_in
    redirect_to :dashboard_logout if not super_user_signed_in?
  end

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

  def member_signed_in?
    !!current_member
  end

  def social_presences
		@social_presences ||= current_member.social_presences if member_signed_in?
		@social_presences ||= []
	end

  def current_blogger()       current_member.blogger if member_signed_in?     end
  def blogger_signed_in?()    !!current_blogger                               end

  def current_super_user()    current_member.super_user if member_signed_in?  end
  def super_user_signed_in?() !!current_super_user                            end


end
