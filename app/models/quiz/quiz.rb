class Quiz
  include Mongoid::Document
  include Mongoid::Timestamps

  field :info, :type => Hash
  field :name, :type => String
  field :description, :type => String
  field :category, :type => String, :default => "general"

  has_many :quiz_questions
  has_many :blog_leaderboards
  has_one :game_leaderboard
end