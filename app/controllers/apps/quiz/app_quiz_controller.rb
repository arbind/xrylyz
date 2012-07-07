class AppQuizController < RylyzAppController

  def self.daily_game(visitor, identifier)
    Quiz::Game.daily_game(visitor, identifier)
  end

  def self.on_load_data(visitor, tokens)
  end

  class ScreenGameController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      wid = tokens['wid']
      qid = -1
      game = AppQuizController.daily_game(visitor, wid)

      capsule = materialize_message_capsule_for_all('load-data')
      capsule.build_events do |messages|
        data = game.level1_questions_as_card
        messages << {displayName:'level1-questions', data: data}

        data = game.level2_questions_as_card
        messages << {displayName:'level2-questions', data: data}

        data = game.level3_questions_as_card
        messages << {displayName:'level3-questions', data: data}
      end

      capsule.notify

    end

    def self.on_select_question(visitor, tokens)
      wid = tokens['wid']
      select = tokens['select']
      game_question = QuizQuestion::GameQuestion.find(select)

      client_events = []
      ctx = {appName: app_name}
      settings = {select: game_question.id.to_s}
      event  = {queue:'screen', type:'navigation', nextScreen:'question', context:ctx, settings:settings}
      client_events << event
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)
    end

  end

  class ScreenQuestionController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      settings = tokens['settings']
      select = settings['select']
      game_question = QuizQuestion::GameQuestion.find(select)
      game = game_question.game

      capsule = materialize_message_capsule_for_all('load-data')

      capsule.build_events do |messages|
        data = game_question.for_display_as_prompt
        messages << {displayName:'prompt', data: data}
      end

      capsule.notify
    end



    def self.on_done(visitor,tokens)
      client_events = []
      ctx = {appName: app_name}
      event  = {queue:'screen', type:'navigation', nextScreen:'game', context:ctx }
      client_events << event
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)
    end


    def self.calculate_score(time)
      100
    end
    
    def self.on_choose_answer(visitor, tokens)
      wid = tokens['wid']

      id = tokens['id']
      game_question = QuizQuestion::GameQuestion.find(id)
      return if 0<game_question.selected_answer

      choice = tokens['choice'].to_i
      time = tokens['time'].to_i
      score = calculate_score time

      game_question.selected_answer = choice
      game_question.time_to_answer = time
      game_question.score = score
      game_question.save

      game = game_question.game

      klass = 'none'
      winner = false
      if game_question.correct_answer == choice
        klass = 'correct'
        status = "That's Correct!"
        # trivia.correct_answers << visitor.for_display
        # placement = trivia.correct_answers.size
        # if 1==placement
        #   status = "You Won!"
        #   klass = 'winner'
        #   winner = true
        # end

        # placement = placement.ordinalize

        # ctx = {appName:app_name, screenName:'trivia-room', displayName:'placement'}
        # data = {placement:placement}
        # event = {queue:'app-server', type:'load-data', context:ctx, data: data}
        # events << event

        # if !winner
        #   ctx = {appName:app_name, screenName:'trivia-room', displayName:'winner'}
        #   data = trivia.correct_answers.first
        #   data['nickname'] = "The winner is #{data['nickname']}"
        #   event = {queue:'app-server', type:'load-data', context:ctx, data: data}
        #   events << event
        # end

      else
        klass = 'wrong'
        status = "You chose poorly"
        # trivia.wrong_answers << visitor.for_display
      end

      # trivia.save

      # ctx = {appName: app_name, screenName:'trivia-room', displayName:'options'}
      # idx = -1
      # data = trivia.options.map { |option| 
      #   idx +=1;
      #   winclass = ""
      #   winclass = "right-#{idx}" if idx == trivia.correct_answer
      #   {option: option, key: idx, winclass:winclass}
      # }
      # event = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # events << event

      # ctx = {appName:app_name, screenName:'trivia-room', displayName:'winner'}
      # data = trivia.correct_answers.first
      # data["nickname"] = "The winner is #{data['nickname']}"
      # event = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # events << event

      events = []
      ctx = {appName:app_name, screenName:'question', displayName:'status'}
      data = {status:status, klass:klass}
      event = {queue:'app-server', type:'load-data', context:ctx, data: data}
      events << event

      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", events)
    end
  end



  class ScreenLeaderboardController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
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
