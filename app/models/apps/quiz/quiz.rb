class Quiz
  include Mongoid::Document
  include Mongoid::Timestamps
  after_initialize :populate_cache

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

  def populate_cache
  game = Speed.of('CACHE quiz.questions') do
    QuizQuestion.where(quiz: self).cache unless questions.nil?
  end

  end

  def self.daily_quiz_for_today() daily_quiz_on(DateTime.now.utc) end
  def self.daily_quiz_for_tomorrow() daily_quiz_on(DateTime.now.utc + 1.day) end

  def self.daily_quiz_on(day) quizes_on(day).first end
  def self.quizes_on(day)

  result = Speed.of("Quiz.quizes_on #{day}") do
    on_day = day.beginning_of_day
    on_next_day = on_day + 1.day
    result = where(is_approved: true).and(online_at: {'$gte'=>on_day}).and(online_at: {'$lt' => on_next_day}).asc(:online_at)
  end

  result
  end

  # adapter
  has_many :game, :class_name => 'Quiz::Game', :inverse_of => :quiz
  class Game
    include Mongoid::Document
    include Mongoid::Timestamps
    after_initialize :populate_cache

    field :key, :type => String, :default => nil;
    field :source_url, :type => String, :default => nil
    field :rating, :type => Integer, :default => -1
    field :comment, :type => String, :default => ''
    field :player_nickname, :type => String, :default => nil

    belongs_to :quiz, index: true
    has_many :questions, :class_name => "QuizQuestion::GameQuestion", :inverse_of => :game
    # has_one :player

    index({ key: 1 }, { unique: true, name: "key_index" })
    index({ source_url: 1 }, { unique: false, name: "source_url_index" })


    def populate_cache
    Speed.of('CACHE: Game game_questions') do
      QuizQuestion::GameQuestion.where(game: self).cache unless quiz.nil?
    end
    end


    def self.create_adapter(quiz, visitor)
    Speed.of("Game.create_adater(quiz) [#{quiz.name}: #{quiz.kind}: #{quiz.topic}]") do
      g = self.create
      g.adapt(quiz, visitor)
    end
    end

    def self.daily_game(visitor)
    adapter = Speed.of("Game.daily_game [#{visitor.wid}]") do
      adapter = where(key: visitor.wid).first
    end

      if adapter.nil?
        q = daily_quiz
        adapter = create_adapter(q, visitor) unless q.nil?
      end

      adapter
    end

    # precondition for adapt: instance has already been created
    def adapt(quiz, visitor)
      self.quiz = quiz
      # QuizQuestion.where(quiz: quiz).cache

      # self.player = player
      self.key = visitor.wid
      self.source_url = visitor.source_url
      self.player_nickname = visitor.nickname
      quiz.questions.each do |q|
        gq = self.questions.create

        Speed.of('game_question.adapt(question)') do
          gq.adapt(q)
        end

      end
      save
      self
    end

    def answered_questions() questions.answered end
    def unanswered_questions() questions.unanswered end

    def answered_correct
      questions.select { |q| q.selected_answer == q.quiz_question.correct_answer }
    end

    def answered_wrong
      questions.reject { |q| q.selected_answer==q.quiz_question.correct_answer or q.selected_answer.zero? }
    end

    def timed_out
      questions.timed_out
    end

    def level1_questions_as_card()
      leveln_questions(1).map(&:for_display_as_card);
    end
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

    def summary
      {
        numTotalQuestions:  questions.count,
        numAnsweredCorrect: answered_correct.count,
        numAnsweredWrong:   answered_wrong.count,
        numTimedOut:        timed_out.count,
      }
    end

    private

    def leveln_questions(level)

    list = Speed.of("game.questions.where(level: #{level}") do
      list = questions.where(level:level).to_a # to_a to load the results from the mongo iterator
    end

    # list = Speed.of("game.questions.select level=#{level}") do
    #   list = questions.select { |q| q.level == level }
    # end

      list
    end

    def self.daily_quiz
    Speed.of("Quiz.daily_quiz_for_today") do
      Quiz.daily_quiz_for_today
    end
    end

  end
end
