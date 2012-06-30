class AppQuizController < RylyzAppController

  def self.quiz
    Quiz.where(name:'Q1').first
  end

  def self.on_load_data(visitor, tokens)
  end

  class ScreenGameController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      qid = -1
      quiz = AppQuizController.quiz
      level1_questions = quiz.questions[0..4].collect do |question| 
        qid += 1
        {
          qid:qid,
          level: question.level,
          category: question.category 
        }
      end
      level2_questions = quiz.questions[5..9].collect do |question| 
        qid += 1
        {
          qid:qid,
          level: question.level,
          category: question.category 
        }
      end
      level3_questions = quiz.questions[10..14].collect do |question| 
        qid += 1
        {
          qid:qid,
          level: question.level,
          category: question.category 
        }
      end

      capsule = materialize_message_capsule_for_all('load-data')
      capsule.build_events do |messages|
        data = level1_questions
        messages << {displayName:'level1-questions', data: data}

        data = level2_questions
        messages << {displayName:'level2-questions', data: data}

        data = level3_questions
        messages << {displayName:'level3-questions', data: data}
      end

    capsule.notify

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
