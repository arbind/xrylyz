class RyVisitor

  attr_accessor :id, :wid, :socket_id, :nickname, :source_url

  def initialize
    self.id = SecureRandom.uuid
    VISITORS[id] = self  # make this visitor available by id
  end

  def for_display
    {
      id: id,
      nickname: nickname,
      source_url: source_url
    }
  end

end

