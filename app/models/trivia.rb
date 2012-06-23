class Trivia
  include Mongoid::Document
  include Mongoid::Timestamps

  field :question, :type => String, :default => ""
  field :options, :type => Array, :default => []
  field :correct_answer, :type => Integer, :default => -1
  field :blog_url, :type => String, :default => ""

end