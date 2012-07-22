class LeaderboardService

  def self.record_score(leaderboard_key, nickname, blog_url, score, member_id=nil, info={}, options={})
    attributes = {
      :leaderboard_key => leaderboard_key,
      :nickname        => nickname,
      :blog_url        => blog_url,
      :score           => score,
      :member_id       => member_id,
      :info            => info
    }

    score = FinalScore.create(attributes)

    leaders = []
    score_in_top = false
    top = leading_players_for_game(leaderboard_key, options)

    top.each do |s|
      score_in_top = true if s.id == score.id
      leaders << s
    end
    leaders << score unless score_in_top

    leaders
  end


  def self.leading_players_for_game(leaderboard_key, options={})
    filter = { :leaderboard_key => leaderboard_key }
    filter[:blog_url] = options[:blog_url] if options[:blog_url]
    limit = options[:limit] || 4

    FinalScore.where(filter).desc(:score).limit(limit)
  end

  def self.leading_blogs_for_game(leaderboard_key, options={})
    nil
  end

  def self.key(*args)
    args.join(".")
  end
end