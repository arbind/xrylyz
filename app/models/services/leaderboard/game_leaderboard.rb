class GameLeaderboard
  include Mongoid::Document
  include Mongoid::Timestamps

  field :game_id, :type => String

  has_many :player_placements
  has_many :blog_placements
end