class Blogger::ShowcaseController < ApplicationController
  include ApplicationHelper
	
  def chat() end
  def blog() end

  def games
		games = Connect4Game.all
		@matches = games.collect do |game| 
			winner = "none"
			winner = game.player(1) if 1 == game.winner
			winner = game.player(2) if 2 == game.winner
			p1 = p2 = "x"
			p1 = game.player(1)
			p2 = game.player(2)
			{
				p1: p1,
				p2: p2,
				winner: winner,
				created_at: game.created_at,
				updated_at: game.updated_at
			} 
		end
  end

  def scratch() end

end
