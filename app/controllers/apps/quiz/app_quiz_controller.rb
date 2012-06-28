class AppQuizController < RylyzAppController

  def self.on_load_data(visitor, tokens)
  end

  class ScreenGameController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
    end

    def self.on_select_question(visitor, tokens)
      wid = tokens['wid']

      client_events = []
      ctx = {appName: app_name}
      event  = {queue:'screen', type:'navigation', nextScreen:'question', context:ctx }
      client_events << event
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)
    end

  end

  class ScreenQuestionController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
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
