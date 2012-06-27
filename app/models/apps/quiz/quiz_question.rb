class QuizQuestion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :question, :type => String
  field :category, :type => String
  field :level, :type => Integer, :default => -1

  field :is_approved, :type => Boolean, :default => false
  field :is_rejected, :type => Boolean, :default => false

  field :info, :type => Hash, :default => {}

  has_many :options
  has_many :blog_leaderboards
  has_one :game_leaderboard

  validates_presence_of :question
  validates_presence_of :category
  validates :level, numericality: { greater_than_or_equal_to: 0 }
end