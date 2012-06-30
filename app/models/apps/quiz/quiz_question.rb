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

  class GameQuestion
    include Mongoid::Document
    include Mongoid::Timestamps

    has_one :question, :class_name => "QuizQuestion"
    belongs_to :game, :class_name => "Quiz::Game", :inverse_of => :questions

    def initialize(quiz_question)
      self.question = quiz_question
    end
  end
end