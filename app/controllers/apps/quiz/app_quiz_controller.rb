class AppQuizController < RylyzAppController

  def self.daily_game(visitor, tokens)
    Quiz::Game.daily_game(visitor, tokens)
  end

  def self.on_load_data(visitor, tokens)
  end

  class ScreenGameController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      qid = -1
      game = AppQuizController.daily_game(visitor, tokens)

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

    def self.on_select_answer(visitor, tokens)
      wid = tokens['wid']
      choice = tokens['choice']

      client_events = []
      ctx = {appName: app_name}
      event  = {queue:'screen', type:'navigation', nextScreen:'game', context:ctx }
      client_events << event
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)
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
