class Sudo

if Rails.env.development? # only available in dev mode

  def self.report_quiz
    total_num_questions = 15
    games  = Quiz::Game.all.to_a
    games_played    = 0
    games_engaged   = 0
    games_completed = 0
    answered_questions = []
    total_num_questions.times { answered_questions << 0 }
    num_from_source_url = {}
    games.each do |game|
      next if total_num_questions != game.questions.count
      answered_game_questions = []
      game.questions.each{|q| answered_game_questions << (q.selected_answer > 0 ? 1: 0) } # 1 tick for each answered question, else 0

      num_answered_questions = answered_game_questions.sum

      num_from_source_url[game.source_url] ||= 0
      num_from_source_url[game.source_url] += 1 if num_answered_questions > 5 # count game played form source_url for 5 or more answers

      games_played    +=1 if num_answered_questions > 1 # game was played as long as 2 questions were answered
      games_engaged   +=1 if num_answered_questions > 5 # game was played as long as 2 questions were answered
      games_completed +=1 if num_answered_questions == total_num_questions # game was played as long as 2 questions were answered

      a = [answered_questions, answered_game_questions ] # set up to add 2 arrays together
      answered_questions = a.transpose.map {|x| x.reduce(:+)} # +1 if question was answered
    end

    puts "#{Util.pluralize(games.count, 'game')} Created"
    puts "#{Util.pluralize(games_played, 'game')} Played at least 1 question"
    puts "#{Util.pluralize(games_engaged, 'game')} Engaged in at least 5 questions"
    puts "#{Util.pluralize(games_completed, 'game')} COMPLETED!"
    answered_questions.each_with_index do |count, i|
      puts "#{Util.pluralize(count, "person")} answered question #{i+1}"
    end
    num_from_source_url.each do |key, val|
      puts "#{Util.pluralize(val, 'person')} played from #{key}"
    end
    nil
  end

  def self.count(clazz)
    "#{Util.pluralize(clazz.all.count, clazz.name)} "
  end

  def self.report()
    puts count(RylyzMember)
    puts count(RylyzMemberPresence)
    puts count(RylyzBlogger)
    puts count(RylyzBloggerSite)
    puts count(RylyzBloggerPlan)
  end


  def self.check(sudo_action)  raise "bad_action" unless sudo_action === SUDO_ACTION end

  def self.delete_all_members(sudo_action)
    check(sudo_action)
    puts "Delete #{RylyzMember.all.delete} RylyzMembers"
    puts "Delete #{RylyzMemberPresence.all.delete} RylyzMemberPresences"
  end

  def self.delete_all_bloggers(sudo_action)
    check(sudo_action)
    puts "Deleted #{RylyzBlogger.all.delete} RylyzBloggers"
    puts "Deleted #{RylyzBloggerSite.all.delete} RylyzBloggerSites"
    puts "Deleted #{RylyzBloggerPlan.all.delete} RylyzBloggerPlans"
  end

  # delete credit cards, visitors, sessions, games

end
end