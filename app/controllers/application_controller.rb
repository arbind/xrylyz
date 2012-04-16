class ApplicationController < ActionController::Base
  helper_method :current_member, :signed_in?, :social_presences, :current_blogger

 protected

  def current_blogger
    blogger_id = session[:blogger_id]
    if blogger_id
      @current_blogger ||= RylyzBlogger.find(blogger_id)
    end
    @current_blogger
  end

  def current_blogger=(blogger)
    blogger_id = nil
    blogger_id = blogger.id.to_s unless blogger.nil?

    @current_blogger = blogger
    session[:blogger_id] = blogger_id
    @current_blogger.mark_sign_in unless @current_blogger.nil?
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

  def signed_in?
    !!current_member
  end

  def social_presences
		@social_presences ||= current_member.social_presences if current_member
		@social_presences ||= []
	end
end
