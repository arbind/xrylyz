class RootController < ApplicationController

	def index
		
		if current_blogger # blogger is logged in
			redirect_to dashboard_path
		elsif current_member # gamer is visiting the site
			# +++ take gamers who are logged in to a cool landing page - profit leaderboard?
			redirect_to	 home_page_url
		else
			redirect_to home_page_url
		end

	end

end