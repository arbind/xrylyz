class Trivia
  include Mongoid::Document
  include Mongoid::Timestamps

  field :question, :type => String, :default => ""
  field :options, :type => Array, :default => []
  field :correct_answer, :type => Integer, :default => -1
  field :blog_url, :type => String, :default => ""
  field :correct_answers, :type => Array, :default => []
  field :wrong_answers, :type => Array, :default => []
  field :winner, :type => String, :default => ""

  belongs_to :blog_trivia, :class_name => "BlogTrivia", :inverse_of => :trivia

  def clear
    self.correct_answers = []
    self.wrong_answers = []
    self.save
  end
end