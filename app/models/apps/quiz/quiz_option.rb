class QuizOption
  include Mongoid::Document
  include Mongoid::Timestamps

  field :answer, :type => String
  field :is_correct, :type => Boolean, :default => false

  belongs_to :question, :class_name => "QuizQuestion", :inverse_of => :options

  validates_presence_of :answer
end