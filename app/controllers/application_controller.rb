class ApplicationController < ActionController::Base
  helper_method :current_member, :member_signed_in?, :social_presences
  helper_method :current_blogger, :blogger_signed_in?
  helper_method :current_super_user, :super_user_signed_in?

  before_filter :check_for_dot_com_domain


protected

  def check_for_dot_com_domain
    redirect to "http://rylyz.com" if ENV['RYLYZ_PLAYER_HOST'].downcase.include? "wygyt."
  end

  def require_member_to_be_signed_in
    redirect_to :dashboard_login, :notice=>"Please sign in first" if not member_signed_in?
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

  def logout_current_member
    @current_member = nil
    session[:member_id] = nil
    session[:signup_confirmation_blogger_oid] = nil
  end

  def current_member=(rylyz_member)
    logout_current_member and return if rylyz_member.nil?

  	member_id = rylyz_member.id.to_s
    session[:member_id] = member_id

    @current_member = rylyz_member  # +++ ? @current_member = RylyzMember.find(member_id)
    @current_member.mark_sign_in
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
