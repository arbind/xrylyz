class QuizQuestion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :question, :type => String # not nil
  field :category, :type => String # not nil
  field :info, :type => Hash
  field :level, :type => Integer # not nil

  field :is_approved, :type => Boolean, :default => false

  has_many :options
  has_many :blog_leaderboards
  has_one :game_leaderboard
end