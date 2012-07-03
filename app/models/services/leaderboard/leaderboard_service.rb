class LeaderboardService

  def self.record_score(leaderboard_key, nickname, blog_url, score, member_id=nil, info={})
    attributes = {
      :leaderboard_key => leaderboard_key,
      :nickname        => nickname,
      :blog_url        => blog_url,
      :score           => score,
      :member_id       => member_id,
      :info            => info
    }

    FinalScore.create(attributes)
  end

  def self.leading_players_for_game(leaderboard_key, options={})
    filter = { :leaderboard_key => leaderboard_key }
    filter[:blog_url] = options[:blog_url] if options[:blog_url]
    limit = options[:limit] || 10

    FinalScore.where(filter).desc(:score).limit(limit)
  end

  def self.leading_blogs_for_game(leaderboard_key, options={})
    nil
  end

  def self.key(*args)
    k = ""
    idx = 0
    args.each do |v|
      k << "." if idx > 0
      k << v.id.to_s
      idx += 1
    end
    k
  end
end