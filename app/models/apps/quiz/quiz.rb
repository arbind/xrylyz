class Quiz
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :kind, :type => String
  field :topic, :type => String
  field :description, :type => String

  field :online_at, :type => DateTime,  :default => Proc.new { DateTime.now.utc.beginning_of_day }
  field :offline_at, :type => DateTime, :default => Proc.new { DateTime.now.utc.beginning_of_day + 1.day }

  field :is_approved, :type => Boolean, :default => false
  field :is_rejected, :type => Boolean, :default => false

  field :is_complete, :type => Boolean, :default => false

  field :info, :type => Hash, :default => {}

  has_and_belongs_to_many :questions, :class_name => "QuizQuestion", :inverse_of => :quiz

  # validates_presence_of :category
  # validates_presence_of :name

  def self.daily_quiz_for_today() daily_quiz_on(DateTime.now.utc) end
  def self.daily_quiz_for_tomorrow() daily_quiz_on(DateTime.now.utc + 1.day) end

  def self.daily_quiz_on(day) quizes_on(day).first end
  def self.quizes_on(day)
    on_day = day.beginning_of_day
    on_next_day = on_day + 1.day
    where(is_approved: true).and(online_at: {'$gte'=>on_day}).and(online_at: {'$lt' => on_next_day}).asc(:online_at)
  end

  # adapter
  has_many :game, :class_name => 'Quiz::Game', :inverse_of => :quiz
  class Game
    include Mongoid::Document
    include Mongoid::Timestamps

    field :key, :type => String, :default => nil;
    field :source_url, :type => String, :default => nil
    field :rating, :type => Integer, :default => -1
    field :comment, :type => String, :default => ''
    field :player_nickname, :type => String, :default => nil

    belongs_to :quiz
    has_many :questions, :class_name => "QuizQuestion::GameQuestion", :inverse_of => :game
    # has_one :player

    def self.create_adapter(quiz, visitor)
      g = self.create
      g.adapt(quiz, visitor)
    end

    def self.daily_game(visitor)
      adapter = where(key: visitor.wid).first
      if adapter.nil?
        q = daily_quiz
        adapter = create_adapter(q, visitor) unless q.nil?
      end
      adapter
    end

    # precondition for adapt: instance has already been created
    def adapt(quiz, visitor)
      self.quiz = quiz
      # self.player = player
      self.key = visitor.wid
      self.source_url = visitor.source_url
      self.player_nickname = visitor.nickname
      quiz.questions.each do |q|
        gq = self.questions.create
        gq.adapt(q)
      end
      save
      self
    end

    def answered_questions() questions.answered end
    def unanswered_questions() questions.unanswered end

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
      Quiz.daily_quiz_for_today
    end
  end
end