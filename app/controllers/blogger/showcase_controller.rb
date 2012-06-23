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

  def trivia
    @trivia = Trivia.new
    @trivias = Trivia.all
  end

  def edit_trivia
    @trivia = Trivia.find(params[:id])
  end

  def save_trivia
    @trivia = Trivia.create(params[:trivia])
    redirect_to :showcase_trivia
  end

  def update_trivia
    option = params[:option]
    @trivia = Trivia.find(params[:id])
    @trivia.update_attributes(params[:trivia])
    @trivia.options << option
    @trivia.save

    redirect_to :showcase_edit_trivia
  end

  def delete_trivia
    @trivia = Trivia.find(params[:id])
    @trivia.destroy

    redirect_to :showcase_trivia
  end
end
