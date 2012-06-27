class BlogLeaderboard
  include Mongoid::Document
  include Mongoid::Timestamps

  field :game_id, :type => String
  field :blog_url, :type => String

  has_many :player_placements
end