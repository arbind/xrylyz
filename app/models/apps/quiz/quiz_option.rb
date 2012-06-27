class QuizOption
  include Mongoid::Document
  include Mongoid::Timestamps

  field :answer, :type => String # not nil
  field :is_correct, :type => Boolean, :default => false
end