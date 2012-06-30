class QuizQuestion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :question, :type => String
  field :category, :type => String
  field :level, :type => Integer, :default => -1

  field :is_approved, :type => Boolean, :default => false
  field :is_rejected, :type => Boolean, :default => false

  field :info, :type => Hash, :default => {}


  has_many :options, :class_name => "QuizOption", :inverse_of => :question

  belongs_to :quiz, :class_name => "Quiz", :inverse_of => :questions


  validates_presence_of :question
  validates_presence_of :category
  validates :level, numericality: { greater_than_or_equal_to: 0 }

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
      puts "ADAPTING #{quiz_question.question}"
      self.quiz_question = quiz_question
      save
      self
    end

    def question() quiz_question.question end
    def category() quiz_question.category end
    def level() quiz_question.level end
    def info() quiz_question.info end
    def options() quiz_question.options end
    def quiz() self.game end
    def test() "test" end

  end

end