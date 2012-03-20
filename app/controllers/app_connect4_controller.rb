class AppConnect4Controller < AppRylyzController

  def self.on_load_data(visitor, tokens)
  end

  class ScreenInputNicknameController < AppRylyzScreenController

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
      event  = {queue:'screen', type:'navigation', nextScreen:'lobby', context:ctx }
     	client_events << event
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)
	  end

  end

  class ScreenLobbyController < AppRylyzScreenController
	  def self.on_load_data(visitor, tokens)
	  	games = Connect4Game.all

	  	client_events = []

      ctx = {appName: app_name, screenName:'lobby', displayName:'overview'}
      data = {num_games: games.count }
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      client_events << event

      ctx = {appName: app_name, screenName:'lobby', displayName:'games'}
      data = games.collect{|game| game.for_display_as_list_item }
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      client_events << event

      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", client_events)
	  end

	  def self.on_start_new_game(visitor, tokens)
	  	wid = tokens["wid"]
	    new_game = Connect4Game.new

	    new_game.player1 = visitor.nickname
	    if new_game.save
	      ctx = {appName: app_name, screenName:'lobby', displayName:'games'}
	      data = new_game.for_display
	      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
	      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

	      client_events = []
	      ctx = {appName: app_name}
	     	settings = { select: new_game.id.to_s }
	      event  = {queue:'screen', type:'navigation', nextScreen:'play-game', context:ctx, settings:settings }
	      client_events << event

	      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", event)
	    else
	    	#+++TODO what if the game fails to save
	    end

	  end

	end

  class ScreenPlayGameController < AppRylyzScreenController
	  def self.on_load_data(visitor, tokens)
      wid = tokens['wid'] || tokens['uid']

      settings = tokens["settings"]
      select = settings["select"]
      game = Connect4Game.find(select)
      ctx = {appName: app_name, screenName:'play-game'}
      event  = {queue:'app-server', type:'load-data', context:ctx, data: ''}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

      #+++ is it required to start a listener thread?
      #PusherChannels.instance.start_private_channel(chat_room.channel_id)
      # this is a 1-way channel - from app to wyjyt - so no need to bind listeners
      PusherChannels.instance.trigger_private_channel_event(wid, "launch-listener", {launchChannel:game.channel_id, scope:'private', wid:wid})

      client_events = []
      ctx = {appName: app_name, screenName:'play-game', displayName:'game-board'}
      data = game.game_board_for_display
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      client_events << event

      ctx = {appName: app_name, screenName:'play-game', displayName:'game-pieces'}
      data = game.game_pieces_for_display
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      client_events << event

      ctx = {appName: app_name, screenName:'play-game', displayName:'player1'}
      data = game.player1_for_display
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      client_events << event

      ctx = {appName: app_name, screenName:'play-game', displayName:'player2'}
      data = game.player2_for_display
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      client_events << event

      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)
      
      # data = chat_room.visitors_for_display
      # ctx = {appName: app_name, screenName:'chat-room', displayName:'people'}
      # event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)

      # game.add_visitor visitor
      # data = visitor.for_display
      # ctx = {appName: app_name, screenName:'chat-room', displayName:'people'}
      # event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      # PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)

	  end

	  def self.on_move(visitor, tokens)
      wid = tokens['wid'] || tokens['uid']

      settings = tokens["settings"]
      select = settings["select"]
      game = Connect4Game.find(select)
      ctx = {appName: app_name, screenName:'play-game'}
      event  = {queue:'app-server', type:'load-data', context:ctx, data: ''}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

	    move = tokens['column']

	    # lookup myplayer num by visitor
	    data = game.move(1, move.to_i)
	    # event = game.move(my_player_num, move.to_i)
      ctx = {appName: app_name, screenName:'play-game', displayName:'game-pieces'}
      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(game.channel_id, "fire-event", event)
	  end


	end

end