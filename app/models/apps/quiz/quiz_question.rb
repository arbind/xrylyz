class QuizQuestion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :level, :type => Integer, :default => -1
  field :category, :type => String

  field :prompt , :type => String
  field :answers , :type => Hash, :default => {} #indexed by integer 1, 2, 3, 4
  field :correct_answer, :type => Integer, :default => -1

  field :member_id, :type => BSON::ObjectId
  field :author_name, :type => String
  field :author_email, :type => String
  field :author_referer, :type => String

  field :is_approved, :type => Boolean, :default => false
  field :is_rejected, :type => Boolean, :default => false
  field :is_for_testing, :type => Boolean, :default => false

  field :last_played_at, :type => DateTime, :default => ->{ 100.years.ago }
  field :info, :type => Hash, :default => {}

  belongs_to :quiz, :class_name => "Quiz", :inverse_of => :questions

  validates_presence_of :question
  validates_presence_of :category
  validates :level, numericality: { greater_than_or_equal_to: 0 }

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
  belongs_to :game_question, :class_name => "QuizQuestion::GameQuestion", :inverse_of => :quiz_question
  class GameQuestion
    include Mongoid::Document
    include Mongoid::Timestamps

    has_one :quiz_question, :class_name => "QuizQuestion"
    belongs_to :game, :class_name => "Quiz::Game", :inverse_of => :questions

    # adapter usage pattern:
    # create then adapt
    # precondition for adapt: instance has already been created
    def adapt(quiz_question)
      self.quiz_question = quiz_question
      save
      self
    end

    def prompt() quiz_question.prompt end
    def options() quiz_question.options end
    def category() quiz_question.category end
    def level() quiz_question.level end
    def info() quiz_question.info end
    def quiz() self.game end

  end

end