class BlogRank

  attr_reader :blog_url, :score, :num_players

  def initialize(blog_url, score, num_players)
    @blog_url = blog_url
    @score = score
    @num_players = num_players
  end
end