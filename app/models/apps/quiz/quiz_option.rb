class QuizOption
  include Mongoid::Document
  include Mongoid::Timestamps

  field :answer, :type => String
  field :is_correct, :type => Boolean, :default => false

  validates_presence_of :answer
end