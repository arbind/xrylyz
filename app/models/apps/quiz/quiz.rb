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
    QuizQuestion.where(quiz: self).cache unless questions.nil?
    # questions.cache unless questions.nil?
  end

  def self.daily_quiz_for_today() daily_quiz_on(DateTime.now.utc) end
  def self.daily_quiz_for_tomorrow() daily_quiz_on(DateTime.now.utc + 1.day) end

  def self.daily_quiz_on(day) quizes_on(day).first end
  def self.quizes_on(day)
beginning_time = Time.now
    on_day = day.beginning_of_day
    on_next_day = on_day + 1.day
    result = where(is_approved: true).and(online_at: {'$gte'=>on_day}).and(online_at: {'$lt' => on_next_day}).asc(:online_at)
end_time = Time.now

# puts "Quiz ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "Quiz find dail_game #{(end_time - beginning_time)}s to handle find quizes_on"
# puts "Quiz ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

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
    # quiz.cache unless quiz.nil?
    # questions.cache unless questions.nil?
  end


    def self.create_adapter(quiz, visitor)
      g = self.create
      g.adapt(quiz, visitor)
    end

    def self.daily_game(visitor)
beginning_time = Time.now
      adapter = where(key: visitor.wid).first
end_time = Time.now

# puts "Game ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "Game find dail_game #{(end_time - beginning_time)}s to handle find adapter"
# puts "Game ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

      if adapter.nil?
beginning_time = Time.now
        q = daily_quiz
end_time = Time.now
# puts "Game ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "Game find dail_game #{(end_time - beginning_time)}s to handle Game.daily_quiz"
# puts "Game ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

beginning_time = Time.now
        adapter = create_adapter(q, visitor) unless q.nil?
end_time = Time.now

# puts "Game ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "Game find dail_game #{(end_time - beginning_time)}s to handle create_adapter"
# puts "Game ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
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
beginning_time = Time.now
        gq = self.questions.create
end_time = Time.now

# puts "adapt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "adapt create GameQuestion #{(end_time - beginning_time)}s to handle gq = self.questions.create"
# puts "adapt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        gq.adapt(q)
      end
beginning_time = Time.now
      save
end_time = Time.now

# puts "adapt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "adapt create Game #{(end_time - beginning_time)}s to handle save"
# puts "adapt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
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
      # list = questions.select { |q| q.level == level }

# beginning_time = Time.now
#       list = questions.where(level:level)
# end_time = Time.now

# puts "LevenN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "LevenN create find LevenN #{(end_time - beginning_time)*1000}ms to handle questions.where(level:level)"
# puts "LevenN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    # list

beginning_time = Time.now
      list = questions.select { |q| q.level == level }
end_time = Time.now

puts "LevenN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts "LevenN create find LevenN #{(end_time - beginning_time)*1000}ms to handle list = questions.select { |q| q.level == level }"
puts "LevenN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
list
    end

    def self.daily_quiz
      Quiz.daily_quiz_for_today
    end
  end
end