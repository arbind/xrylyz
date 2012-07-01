class Quiz
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :topic, :type => String, :default => "general"
  field :description, :type => String

  field :info, :type => Hash, :default => {}

  has_many :questions, :class_name => "QuizQuestion", :inverse_of => :quiz
  has_many :blog_leaderboards
  has_one :game_leaderboard

  validates_presence_of :category
  validates_presence_of :name


  # adapter
  belongs_to :game, :class_name => 'Quiz::Game', :inverse_of => :quiz
  class Game
    include Mongoid::Document
    include Mongoid::Timestamps

    field :playing_referer, :type => String

    has_one :quiz
    has_many :questions, :class_name => "QuizQuestion::GameQuestion", :inverse_of => :game
    # has_one :player

    def self.create_adapter(quiz, player)
      g = self.create
      g.adapt(quiz,player)
    end

    # precondition for adapt: instance has already been created
    def adapt(quiz, player)
      self.quiz = quiz
      # self.player = player
      quiz.questions.each do |q|
        gq = self.questions.create
        gq.adapt(q)
      end
      save
      self
    end
  end
end