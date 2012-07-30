class QuizQuestion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :level, :type => Integer, :default => -1
  field :category, :type => String
  field :season, :type => String, :default => ""

  field :prompt , :type => String
  field :answers , :type => Hash, :default => {} #indexed by integer 1, 2, 3, 4
  field :correct_answer, :type => Integer, :default => -1
  field :reflection , :type => String

  field :member_id, :type => BSON::ObjectId
  field :author_name, :type => String
  field :author_email, :type => String
  field :author_referer, :type => String

  field :is_approved, :type => Boolean, :default => false
  field :is_rejected, :type => Boolean, :default => false

  field :is_complete, :type => Boolean, :default => false

  field :last_played_at, :type => DateTime, :default => ->{ 100.years.ago }
  field :info, :type => Hash, :default => {}

  has_and_belongs_to_many :quiz, :class_name => "Quiz", :inverse_of => :questions
  before_save :before_save_check_if_complete
  # validates_presence_of :question
  # validates_presence_of :category
  # validates :level, numericality: { greater_than_or_equal_to: 0 }

  scope :level1, where(level: 1)
  scope :level2, where(level: 2)
  scope :level3, where(level: 3)

  # scope :unanswered, where(selected_answer: )
  scope :approved, where(is_approved: true)
  scope :rejected, where(is_rejected: true)

  scope :complete, where(is_complete: true)
  scope :unused, where(quiz: nil)
  scope :unused_level1, where(quiz: nil).and(level: 1)
  scope :unused_level2, where(quiz: nil).and(level: 2)
  scope :unused_level3, where(quiz: nil).and(level: 2)

  def before_save_check_if_complete
    complete = true
    complete = false if 0 > level
    complete = false if 0 > correct_answer
    complete = false unless (is_approved or is_rejected)
    complete = false if category.blank?
    complete = false if prompt.blank?
    complete = false if answer1.blank?
    complete = false if answer2.blank?
    complete = false if answer3.blank?
    complete = false if answer4.blank?

    self.is_complete = complete
    return true
  end

  def answer_list
    @a ||= []
    if @a.empty?
      @a << answers["1"] || ""
      @a << answers["2"] || ""
      @a << answers["3"] || ""
      @a << answers["4"] || ""
    end
    @a
  end

  def [](idx)
   answers[idx.to_s]
  end
  def []=(idx, val)
    if (0<idx.to_i and idx.to_i<5)
      answers[idx.to_s] = val
    end
  end

  def answer1()  answers["1"] end
  def answer2()  answers["2"] end
  def answer3()  answers["3"] end
  def answer4()  answers["4"] end
  def answer1=(answer)  answers["1"]=answer end
  def answer2=(answer)  answers["2"]=answer end
  def answer3=(answer)  answers["3"]=answer end
  def answer4=(answer)  answers["4"]=answer end

  def member
    if member_id
      @member ||= RylyzMember.find(member_id)
    end
  end

  # adapter
  has_many :game_question, :class_name => "QuizQuestion::GameQuestion", :inverse_of => :quiz_question

  class GameQuestion
    include Mongoid::Document
    include Mongoid::Timestamps
    after_initialize :populate_cache

    field :selected_answer, :type => Integer, :default => -1
    field :time_to_answer, :type => Integer, :default => -1
    field :score, :type => Integer, :default => -1
    field :level, :type => Integer, :default => -1

    belongs_to :quiz_question, :class_name => "QuizQuestion", index: true
    belongs_to :game, :class_name => "Quiz::Game", :inverse_of => :questions, index: true


    scope :answered,    where(selected_answer: {'$gt' => -1})
    scope :unanswered,  where(selected_answer: {'$lt' => 0})
    scope :timed_out,   where(selected_answer: 0)

    index({ level: 1 }, { unique: false, name: "level_index" })

    def populate_cache
      # game.cache unless game.nil?
    end

    # adapter usage pattern:
    # create then adapt
    # precondition for adapt: instance has already been created
    def adapt(quiz_question)
    Speed.of('game_question.adapt(quiz_question)') do
      self.quiz_question = quiz_question
      self.level = quiz_question.level
      save
    end
      self
    end

    def prompt() quiz_question.prompt end
    def answer1() quiz_question.answer1 end
    def answer2() quiz_question.answer2 end
    def answer3() quiz_question.answer3 end
    def answer4() quiz_question.answer4 end
    def correct_answer() quiz_question.correct_answer end
    def reflection() quiz_question.reflection end
    def category() quiz_question.category end
    def season() quiz_question.season end
    # def level() quiz_question.level end   # this is now indexed
    def info() quiz_question.info end

    def leaderboard_key
      LeaderboardService.key(game.leaderboard_key, quiz_question.id)
    end

    def for_display_as_card
      answer_class = "" # default to not answered
      if (selected_answer.zero?)
        answer_class = "ryTimeOver"
      elsif (correct_answer == selected_answer)
        answer_class = "ryCorrect"
      elsif (0<selected_answer)
        answer_class = "ryWrong" 
      end
      {
        id: _id,
        level: level,
        category: category,
        answered: selected_answer > -1,
        answer_class: answer_class
      }
    end

    def for_display_as_prompt
      {
        id: _id,
        level: level,
        category: category,
        season: season,
        prompt: prompt,
        answer1: answer1,
        answer2: answer2,
        answer3: answer3,
        answer4: answer4
      }
    end

    def for_display_as_final
      {
        id: _id,
        level: level,
        category: category,
        season: season,
        prompt: prompt,
        reflection: reflection,
        correct_answer: correct_answer,
        selected_answer: selected_answer,
        time_to_answer: time_to_answer,
        score: score,
        info: info
      }
    end

  end

end