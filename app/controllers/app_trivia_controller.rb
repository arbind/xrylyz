class AppTriviaController < RylyzAppController

  def self.on_load_data(visitor, tokens)
  end

  def self.current_game
    trivia = nil
    if BlogTrivia.all.size > 0
      idx = self.blog_idx
      blog = BlogTrivia.all[idx]
      trivia = blog.current_trivia
    end
    trivia
  end

  def self.up1_blog_idx
    b = ActiveBlog.first
    b.blog_idx += 1
    b.save
  end

  def self.blog_idx
    if ActiveBlog.all.size == 0
      ActiveBlog.create
    end

    b = ActiveBlog.first
    if b.blog_idx >= BlogTrivia.all.size
      b.blog_idx = 0
      b.save
    end

    b.blog_idx
  end

  def self.on_timer_tick
    puts "=== tick ==="

    self.play_next_trivia
    self.notify_players
  end

  def self.play_next_trivia
    trivia = nil
    if BlogTrivia.all.size > 0
      b_idx = self.blog_idx
      blog = BlogTrivia.all[b_idx]
      trivia = blog.next_trivia
      trivia.clear if trivia
      self.up1_blog_idx
    end
    trivia
  end

  def self.notify_players
    trivia = AppTriviaController.current_game
    events = []

    ctx = {appName: app_name, screenName:'trivia-room', displayName:'question'}
    data = {question: trivia.question, url: trivia.blog_url}
    event = {queue:'app-server', type:'load-data', context:ctx, data: data}
    events << event

    ctx = {appName: app_name, screenName:'trivia-room', displayName:'status'}
    data = {status:'pick your answer'}
    event = {queue:'app-server', type:'load-data', context:ctx, data: data}
    events << event

    ctx = {appName:app_name, screenName:'trivia-room', displayName:'placement'}
    data = {placement:'-'}
    event = {queue:'app-server', type:'load-data', context:ctx, data: data}
    events << event

    ctx = {appName:app_name, screenName:'trivia-room', displayName:'winner'}
    data = {nickname:'', source_url:''}
    event = {queue:'app-server', type:'load-data', context:ctx, data: data}
    events << event

    ctx = {appName: app_name, screenName:'trivia-room', displayName:'options'}
    idx = -1
    data = trivia.options.map { |option| idx +=1; {option: option, key: idx}}
    event = {queue:'app-server', type:'load-data', context:ctx, data: data}
    events << event

    PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", events)
  end

  class ScreenTriviaRoomController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
      wid = tokens['wid']

      trivia = AppTriviaController.current_game
      events = []

      ctx = {appName: app_name, screenName:'trivia-room', displayName:'question'}
      data = {question: trivia.question, url: trivia.blog_url}
      event = {queue:'app-server', type:'load-data', context:ctx, data: data}
      events << event

      ctx = {appName: app_name, screenName:'trivia-room', displayName:'status'}
      data = {status:'pick your answer'}
      event = {queue:'app-server', type:'load-data', context:ctx, data: data}
      events << event

      ctx = {appName: app_name, screenName:'trivia-room', displayName:'options'}
      idx = -1
      data = trivia.options.map { |option| idx +=1; {option: option, key: idx}}
      event = {queue:'app-server', type:'load-data', context:ctx, data: data}
      events << event

      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", events)
    end

    def self.on_choose(visitor, tokens)
      wid = tokens['wid']

      choice = tokens['choice'].to_i
      trivia = AppTriviaController.current_game

      events = []

      if trivia.correct_answer == choice
        status = "Correct Answer"
        trivia.correct_answers << visitor.for_display
        placement = trivia.correct_answers.size

        ctx = {appName:app_name, screenName:'trivia-room', displayName:'placement'}
        data = {placement:placement}
        event = {queue:'app-server', type:'load-data', context:ctx, data: data}
        events << event
      else
        status = "Wrong Answer (#{trivia.correct_answer}) #{tokens['choice']}"
        trivia.wrong_answers << visitor.for_display
      end

      trivia.save


      ctx = {appName:app_name, screenName:'trivia-room', displayName:'winner'}
      data = trivia.correct_answers.first
      event = {queue:'app-server', type:'load-data', context:ctx, data: data}
      events << event

      ctx = {appName:app_name, screenName:'trivia-room', displayName:'status'}
      data = {status:status}
      event = {queue:'app-server', type:'load-data', context:ctx, data: data}
      events << event

      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", events)
    end
  end
end