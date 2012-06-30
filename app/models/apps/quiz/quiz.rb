class Quiz
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :category, :type => String, :default => "general"
  field :description, :type => String

  field :info, :type => Hash, :default => {}

  has_many :questions, :class_name => "QuizQuestion", :inverse_of => :quiz
  has_many :blog_leaderboards
  has_one :game_leaderboard

  validates_presence_of :category
  validates_presence_of :name
end