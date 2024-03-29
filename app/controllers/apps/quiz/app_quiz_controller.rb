class AppQuizController < RylyzAppController

  def self.daily_game(visitor)
    Quiz::Game.daily_game(visitor)
  end

  def self.time_till_next_quiz
    q = Quiz.daily_quiz_for_tomorrow
    return nil if q.nil?
    Util.distance_of_time_in_words_to_now(q.online_at.utc.beginning_of_day) # mongoid? have to reset to beginning of day?
    # try test
    # t = Time.strptime('07/30/2012', "%m/%d/%Y").utc.beginning_of_day
    # q = Quiz.daily_quiz_for_today
    # q.online_at = t
    # q.online_at  -> does not store time at beginning of day!
  end

  def self.on_load_data(visitor, tokens)
  end


  class ScreenGameController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid']

    game = Speed.of('AppQuizController.daily_game(visitor)') do
      game = AppQuizController.daily_game(visitor)
    end

      if game.nil?
        cap.show_screen('splash').fire2player(wid)
        return
      end
    questions_left = Speed.of('questions_left = game.unanswered_questions.count') do
      questions_left = game.unanswered_questions.count
    end
      if 0 < questions_left
        title = "You have #{Util.pluralize(questions_left, 'more question')} to go!"
      else
        title = "Congratulations!" # add total score
      end

      if questions_left.zero?
        cap.show_screen('game-over').fire2player(wid)
        return
      end

      invite_link_data = {inviteUrl: Util.invite_href(game.source_url)}

    level1_questions = Speed.of('level1_questions = game.level1_questions_as_card') do
      level1_questions = game.level1_questions_as_card
    end
    level2_questions = Speed.of('level2_questions = game.level1_questions_as_card') do
      level2_questions = game.level2_questions_as_card
    end
    level3_questions = Speed.of('level3_questions = game.level1_questions_as_card') do
      level3_questions = game.level3_questions_as_card
    end

    Speed.of('game.on_load capsule fire2player') do
      cap.
        show_data('game-title', {title: title}).
        show_data('level1-questions', level1_questions).
        show_data('level2-questions', level2_questions).
        show_data('level3-questions', level3_questions).
        show_data('invite-link', invite_link_data).
        fade_out('#ryLoadingScreen').
        fire2player(wid)
    end

    end

    def self.on_select_question(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid']
      select = tokens['select']
        cap.exception("Nothing Selected").fire2player(wid) and return if !select

    game_question = Speed.of('QuizQuestion::GameQuestion.find(select)') do
      game_question = QuizQuestion::GameQuestion.find(select)
    end
        cap.exception("Game Question Not Found").fire2player(wid) and return if !game_question

      settings = {select: game_question.id.to_s}
    Speed.of('game.on_select capsule fire2player') do
      cap.show_screen('question', settings).fire2player(wid)
    end

    end

  end

  class ScreenQuestionController < RylyzScreenController
    @@correct_list = [
     "that's correct!",
     "on the money!",
     "star",
     "nice!",
     "yep!",
     "affirmative",
     "way to go!",
     "bueno",
     "correctomundo!",
     "you got it!",
     "that's right!",
     "you rock!",
     "sweet!",
     "yes!",
     "perfect!",
     "precisely!",
     "right on!"
   ]

    @@wrong_list = [
    "nice try - but no",
     "not quite",
     "so close",
     "negative",
     "no cigar",
     "not easy - right?",
     "nope",
     "almost"
   ]

    def self.on_load_data(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid']
      settings = tokens['settings']
      select = settings['select']
beginning_time = Time.now
      game_question = QuizQuestion::GameQuestion.find(select)
end_time = Time.now

# puts "on_load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "on_load count unanswered questions #{(end_time - beginning_time)}s to handle finding game question"
# puts "on_load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


beginning_time = Time.now
      status_data = {status:'', klass:'', reflection:''}
      prompt_data = game_question.for_display_as_prompt
      cap.
        show_data('status', status_data).
        show_data('prompt', prompt_data).
        call_javascript('startPhasePromptQuestion', {question_id: select}).
        fade_out('#ryLoadingScreen').
        fire2player(wid)
end_time = Time.now

# puts "on_load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# puts "on_load count unanswered questions #{(end_time - beginning_time)}s to handle firing capsule"
# puts "on_load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    end

    def self.calculate_score(time)
      Random.rand(100)
    end

    def self.on_choose_answer(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid']

      id = tokens['id']
      game_question = QuizQuestion::GameQuestion.find(id)
      return if -1<game_question.selected_answer

      choice = tokens['choice'].to_i
      time = tokens['time'].to_i
      score = calculate_score time

      game_question.selected_answer = choice
      game_question.time_to_answer = time
      game_question.score = score
      game_question.save

      game = game_question.game

      # key = game_question.leaderboard_key
      # leaderboard = LeaderboardService.record_score(key, wid, "some_url", score, nil)

      answerClasses = []
      (1..4).each do |n|
        klass = (n == game_question.correct_answer ? 'ryCorrect' : 'ryWrong')
        cap.add_css_class(".ryAnswer#{n}", klass)
      end

      klass = 'none'
      if game_question.correct_answer == choice
        klass = 'ryCorrect'
        status = @@correct_list.sample
      else
        klass = 'ryWrong'
        status = @@wrong_list.sample
      end
      status_data = {klass:klass, status:status, reflection:game_question.reflection}
      cap.
        show_data('status', status_data).
        # show_data('leaders', leaderboard).
        call_javascript('startPhaseFinished').
        fire2player(wid);
    end


    def self.on_time_over(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid']

      id = tokens['id']
      game_question = QuizQuestion::GameQuestion.find(id)
      return if -1<game_question.selected_answer

      time = tokens['time'].to_i
      score = calculate_score time

      game_question.selected_answer = 0
      game_question.time_to_answer = time
      game_question.score = score
      game_question.save

      game = game_question.game

      # key = game_question.leaderboard_key
      # leaderboard = LeaderboardService.leading_players_for_game(key)

      answerClasses = []
      (1..4).each do |n|
        klass = (n == game_question.correct_answer ? 'ryCorrect' : 'ryWrong')
        cap.add_css_class(".ryAnswer#{n}", klass)
      end

      klass = 'ryTimeOver'
      status = "Time Over!"
      status_data = {klass:klass, status:status, reflection:game_question.reflection}
      cap.
        show_data('status', status_data).
        # show_data('leaders', leaderboard).
        call_javascript('startPhaseFinished').
        fire2player(wid);
    end

  end

  class ScreenGameOverController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid']
      game = AppQuizController.daily_game(visitor)

      summary_data = game.summary
      
      invite_link_data = {inviteUrl: Util.invite_href(game.source_url)}

      msg  = "You got #{game.answered_correct.count} right out of #{game.questions.count}!"
      bookmark = "Bookmark this site to play again tomorrow!"
      come_back = "A new set of trivia is released each day of the Olympics."
      signup = "Signup to install this widget on your own site."
      signup_href = "http://rylyz.com/play" # add lRef=xyz for the blogger that has this site key
      next_quiz = ""
      time_till_next_quiz = AppQuizController.time_till_next_quiz
      unless time_till_next_quiz.nil?
        next_quiz = "#{time_till_next_quiz.capitalize} more until a new daily quiz!"
      end
      msg_data = {msg: msg, come_back: come_back, next_quiz: next_quiz, bookmark: bookmark, signup:signup, signup_href: signup_href}
      cap.
        show_data('closing-message', msg_data).
        show_data('invite-link', invite_link_data).
        fade_out('#ryLoadingScreen').
        fire2player(wid)
    end
  end

  class ScreenLeaderboardController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid']
      game = AppQuizController.daily_game(visitor)

      key = game.leaderboard_key
      leaderboard = LeaderboardService.leading_players_for_game(key)

      # cap = materialize_message_capsule_for_all('load-data')
      # cap.build_events do |messages|
      #   data = leaderboard
      #   messages << {displayName:'leaders', data: data}
      # end

      # cap.notify
    end
  end

  class ScreenSubmitQuestionController < RylyzScreenController
  end

  class ScreenInputNicknameController < RylyzScreenController
    def self.on_data_input(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid']

      formMetadata = tokens['formData']
      inputDataSet = formMetadata['dataSet']
      nicknameInput = inputDataSet['nickname']
      nickname = nicknameInput['value']
      visitor.nickname = nickname

      client_events = []

      event  = {queue:'app-server', type:'update-me', data: visitor.for_display}
      client_events << event

      ctx = {appName: app_name}
      event  = {queue:'screen', type:'navigation', nextScreen:'game', context:ctx }
      client_events << event
      PusherChannels.instance.trigger_presence_channel_event(wid, "fire-event", client_events)
    end
  end

end
