class RootController < ApplicationController

	def index
		
		if current_blogger # blogger is logged in
			redirect_to dashboard_url
		elsif current_member # gamer is visiting the site
			# +++ take gamers who are logged in to a cool landing page - profit leaderboard?
			render "website/chat_plays/profiting", :layout => "chat_plays"
		else
			redirect_to home_page_url
		end

	end

end