class BlogTrivia
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, :type => String, :default => ""
  field :trivia_idx, :type => Integer, :default => 0

  has_many :trivias, :class_name => "Trivia", :inverse_of => :blog_trivia

  def current_trivia
   if trivias.size > 0
      idx = current_idx
      trivias[idx]
    end
  end

  def current_idx
    if self.trivia_idx == trivias.size
      self.trivia_idx = 0
      save
    end
    self.trivia_idx
  end

  def next_trivia
    size = self.trivias.size
    trivia = nil
    if size > 0
      idx = self.current_idx
      trivia = trivias[idx]
      trivia.clear
      self.trivia_idx += 1
      self.save
    end
    trivia
  end
end