class AppQuizController < RylyzAppController

  def self.daily_game(visitor, identifier)
    Quiz::Game.daily_game(visitor, identifier)
  end

  def self.on_load_data(visitor, tokens)
  end

  class ScreenGameOldController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      cap = capsule
      wid = tokens['wid']

      game = AppQuizController.daily_game(visitor, wid)
      cap.show_data('level1-rset', game.level1_questions_as_card)
      # cap.show_data('level2-questions', game.level2_questions_as_card)
      # cap.show_data('level3-questions', game.level3_questions_as_card)
      cap.fire2player(wid)
    end
  end

  class ScreenGameController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      cap = capsule
      wid = tokens['wid']

      game = AppQuizController.daily_game(visitor, wid)
      cap.show_data('level1-questions', game.level1_questions_as_card)
      cap.show_data('level2-questions', game.level2_questions_as_card)
      cap.show_data('level3-questions', game.level3_questions_as_card)
      cap.fire2player(wid)
    end

    def self.on_select_question(visitor, tokens)
      cap = capsule
      wid = tokens['wid']
      select = tokens['select']
        cap.exception("Nothing Selected").fire2player(wid) and return if !select

      game_question = QuizQuestion::GameQuestion.find(select)
        cap.exception("Game Question Not Found").fire2player(wid) and return if !game_question

      settings = {select: game_question.id.to_s}
      cap.show_screen('question', settings).fire2player(wid)
    end

  end

  class ScreenQuestionController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      cap = capsule
      wid = tokens['wid']
      settings = tokens['settings']
      select = settings['select']
      game_question = QuizQuestion::GameQuestion.find(select)

      prompt_data = game_question.for_display_as_prompt
      cap.show_data('prompt', prompt_data).call_javascript('startPhasePromptQuestion', {question_id: select}).fire2player(wid)
    end


    def self.calculate_score(time)
      Random.rand(100)
    end

    def self.on_choose_answer(visitor, tokens)
      cap = capsule
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

      key = game_question.leaderboard_key
      leaderboard = LeaderboardService.record_score(key, wid, "some_url", score, nil)

      klass = 'none'
      if game_question.correct_answer == choice
        klass = 'correct'
        status = "That's Correct!"
      else
        klass = 'wrong'
        status = "You chose poorly"
      end

      status_data = {status:status, klass:klass}
      capsule.show_data('status', status_data).show_data('leaders', leaderboard).call_javascript('startPhaseFinished').fire2player(wid);
    end


    def self.on_time_over(visitor, tokens)
      cap = capsule
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

      key = game_question.leaderboard_key
      leaderboard = LeaderboardService.leading_players_for_game(key)

      klass = 'time-over'
      status = "Time Over!"

      status_data = {status:status, klass:klass}
      capsule.show_data('status', status_data).show_data('leaders', leaderboard).call_javascript('startPhaseFinished').fire2player(wid);
    end


    def self.on_hint(visitor, tokens)
      wid = tokens['wid']

      id = tokens['id']
      game_question = QuizQuestion::GameQuestion.find(id)
      return if -1<game_question.selected_answer
    end

  end

  class ScreenLeaderboardController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      wid = tokens['wid']
      game = AppQuizController.daily_game(visitor, wid)

      key = game.leaderboard_key
      leaderboard = LeaderboardService.leading_players_for_game(key)

      capsule = materialize_message_capsule_for_all('load-data')
      capsule.build_events do |messages|
        data = leaderboard
        messages << {displayName:'leaders', data: data}
      end

      capsule.notify
    end
  end

  class ScreenSubmitQuestionController < RylyzScreenController
  end

  class ScreenInputNicknameController < RylyzScreenController
    def self.on_data_input(visitor, tokens)
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
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)
    end
  end

end
