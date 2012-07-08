class Quiz
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :kind, :type => String
  field :topic, :type => String
  field :description, :type => String

  field :is_approved, :type => Boolean, :default => false
  field :is_rejected, :type => Boolean, :default => false

  field :is_complete, :type => Boolean, :default => false

  field :info, :type => Hash, :default => {}

  has_and_belongs_to_many :questions, :class_name => "QuizQuestion", :inverse_of => :quiz

  # validates_presence_of :category
  # validates_presence_of :name


  # adapter
  belongs_to :game, :class_name => 'Quiz::Game', :inverse_of => :quiz
  class Game
    include Mongoid::Document
    include Mongoid::Timestamps

    field :key, :type => String
    field :playing_referer, :type => String

    has_one :quiz
    has_many :questions, :class_name => "QuizQuestion::GameQuestion", :inverse_of => :game
    # has_one :player

    def self.create_adapter(quiz, identifier)
      g = self.create
      g.adapt(quiz, identifier)
    end

    def self.daily_game(visitor, identifier)
      adapter = where(key: identifier).first
      adapter ||= create_adapter(daily_quiz, identifier)
    end

    # precondition for adapt: instance has already been created
    def adapt(quiz, identifier)
      self.quiz = quiz
      # self.player = player
      self.key = identifier
      quiz.questions.each do |q|
        gq = self.questions.create
        gq.adapt(q)
      end
      save
      self
    end

    def level1_questions_as_card() leveln_questions(1).map(&:for_display_as_card); end
    def level2_questions_as_card() leveln_questions(2).map(&:for_display_as_card); end
    def level3_questions_as_card() leveln_questions(3).map(&:for_display_as_card); end

    def level1_questions_as_prompt() leveln_questions(1).map(&:for_display_as_prompt); end
    def level2_questions_as_prompt() leveln_questions(2).map(&:for_display_as_prompt); end
    def level3_questions_as_prompt() leveln_questions(3).map(&:for_display_as_prompt); end

    def level1_questions_as_final() leveln_questions(1).map(&:for_display_as_final); end
    def level2_questions_as_final() leveln_questions(2).map(&:for_display_as_final); end
    def level3_questions_as_final() leveln_questions(3).map(&:for_display_as_final); end

    def leaderboard_key
      LeaderboardService.key(quiz.id)
    end

    private

    def leveln_questions(level)
      questions.select { |q| q.level == level }
    end

    def self.daily_quiz
      Quiz.all.first
    end
  end
end