class RootController < ApplicationController

	def index
		
		if current_blogger # blogger is logged in
			render "blogger/dashboard/index", :layout => "dashboard"
		elsif current_member # gamer is visiting the site
			# +++ take gamers who are logged in to a cool landing page - profit leaderboard?
			render "website/chat_plays/profiting", :layout => "chat_plays"
		else
			render "website/chat_plays/index", :layout => "chat_plays"
		end

	end

end