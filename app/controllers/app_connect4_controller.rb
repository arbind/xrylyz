class AppConnect4Controller < RylyzAppController

	# +++TODO
	# Send Message: Its your turn, only to wid
	# Send Message: You Won / Lost once game is over to wid


  def self.on_load_data(visitor, tokens)
  end

	  def self.on_join_game(visitor, tokens)
      cap = materialize_capsule
	  	wid = tokens["wid"]
      select = tokens["select"]
      game = Connect4Game.find(select)

      unless (visitor==game.player1_visitor )
		    game.player2_visitor = visitor

		    game.game_is_in_progress = true
	  	  game.player_to_act = 1
	  	  game.save
	  	end
      settings = { select: game.id.to_s }
      cap.show_screen('play-game', settings)
         .fire2player(game.player1_visitor.wid)
         .fire2player(game.player2_visitor.wid)  unless game.player2_visitor.nil?
      cap.clear_events
      # ctx = {appName: app_name}
     	# settings = { select: game.id.to_s }
      # event  = {queue:'screen', type:'navigation', nextScreen:'play-game', context:ctx, settings:settings }
      # PusherChannels.instance.trigger_private_channel_event(game.player1_visitor.wid, "fire-event", event)
      # PusherChannels.instance.trigger_private_channel_event(game.player2_visitor.wid, "fire-event", event) unless game.player2_visitor.nil?

      return if game.player2_visitor.nil?

      cap.screen_name = 'play-game'
      data = {status:"Game has started! Its your turn."}
      cap.show_data('game-status', data)
      cap.fire2player(game.player1_visitor.wid)
      cap.clear_events

      data = {status:"Game has started! Waiting for #{game.player1_visitor.nickname} to move."}
      cap.show_data('game-status', data)
      cap.fire2player(game.player2_visitor.wid)

			# ctx = {appName: app_name, screenName:'play-game', displayName:'game-status'}
			# data = {status:"Game has started! Its your turn."}
			# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # PusherChannels.instance.trigger_private_channel_event(game.player1_visitor.wid, "fire-event", event)
			# data = {status:"Game has started! Waiting for #{game.player1_visitor.nickname} to move."}
			# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # PusherChannels.instance.trigger_private_channel_event(game.player2_visitor.wid, "fire-event", event)
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

      cap.show_me(visitor).show_screen('lobby').fire2player(wid)

      # client_events = []
      # event  = {queue:'app-server', type:'update-me', data: visitor.for_display}
     	# client_events << event
      # ctx = {appName: app_name}
      # event  = {queue:'screen', type:'navigation', nextScreen:'lobby', context:ctx }
     	# client_events << event
      # PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)
	  end

  end

  class ScreenLobbyController < RylyzScreenController
	  def self.on_load_data(visitor, tokens)
      cap = materialize_capsule
	  	games = Connect4Game.all

	  	games.each do |game|
	  		game.destroy if not game.is_active?
	  	end

	  	# only show games where player 1 is waiting for a player.
	  	games = games.select { |game| game.player2_visitor.nil? and not game.player1_visitor.nil? }

      data = games.collect{|game| game.for_display_as_list_item }
      cap.show_data('games', data).fire2app(app_uid)
      # # ctx = {appName: app_name, screenName:'lobby', displayName:'overview'}
      # # data = {num_games: games.count }
      # # event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # # client_events << event

      # client_events = []
      # ctx = {appName: app_name, screenName:'lobby', displayName:'games'}
      # data = games.collect{|game| game.for_display_as_list_item }
      # event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # client_events << event

      # PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", client_events)
	  end

	  def self.on_start_new_game(visitor, tokens)
	  	wid = tokens["wid"]
	    new_game = Connect4Game.new

	    new_game.player1_visitor = visitor

	    if new_game.save
        cap = materialize_capsule
        data = new_game.for_display_as_list_item
        cap.add_item('games', data).fire2app(app_uid)
        cap.clear_events
	      # ctx = {appName: app_name, screenName:'lobby', displayName:'games'}
	      # data = new_game.for_display_as_list_item
	      # event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
	      # PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

        settings = { select: new_game.id.to_s }
        cap.show_screen('play-game', settings)
        cap.fire2player(wid)

        # client_events = []
	      # ctx = {appName: app_name}
	     	# settings = { select: new_game.id.to_s }
	      # event  = {queue:'screen', type:'navigation', nextScreen:'play-game', context:ctx, settings:settings }
	      # client_events << event

	      # PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", event)
	    else
	    	#+++TODO what if the game fails to save
	    end

	  end
	end

  class ScreenPlayGameController < RylyzScreenController
	  def self.on_load_data(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid'] || tokens['uid']

      settings = tokens["settings"]
      select = settings["select"]
      game = Connect4Game.find(select)
      cap.show_data(nil, '')
      cap.fire2app(app_uid)
      cap.clear_events
      # ctx = {appName: app_name, screenName:'play-game'}
      # event  = {queue:'app-server', type:'load-data', context:ctx, data: ''}
      # PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

      #+++ is it required to start a listener thread?
      #PusherChannels.instance.start_private_channel(chat_room.channel_id)
      # this is a 1-way channel - from app to wygyt - so no need to bind listeners
      PusherChannels.instance.trigger_private_channel_event(wid, "launch-listener", {launchChannel:game.channel_id, scope:'private', wid:wid})


      data = game.game_board_for_display
      cap.show_data('game-board', data)

      data = game.game_pieces_for_display
      cap.show_data('game-pieces', data)

      data = game.player1_for_display
      cap.show_data('player1', data)

      data = game.player2_for_display
      cap.show_data('player2', data)
      
      cap.fire2player(wid)
      # client_events = []
      # ctx = {appName: app_name, screenName:'play-game', displayName:'game-board'}
      # data = game.game_board_for_display
      # event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # client_events << event

      # ctx = {appName: app_name, screenName:'play-game', displayName:'game-pieces'}
      # data = game.game_pieces_for_display
      # event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # client_events << event

      # ctx = {appName: app_name, screenName:'play-game', displayName:'player1'}
      # data = game.player1_for_display
      # event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # client_events << event

			# ctx = {appName: app_name, screenName:'play-game', displayName:'player2'}
			# data = game.player2_for_display
			# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
			# client_events << event

      # PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", client_events)

      # # data = chat_room.visitors_for_display
      # # ctx = {appName: app_name, screenName:'chat-room', displayName:'people'}
      # # event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      # # PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)
 
      # # game.add_visitor visitor
      # # data = visitor.for_display
      # # ctx = {appName: app_name, screenName:'chat-room', displayName:'people'}
      # # event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      # # PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)
	  end

		def self.on_move(visitor, tokens)
      cap = materialize_capsule
      wid = tokens['wid'] || tokens['uid']

      settings = tokens["settings"]
      #send exception if !settings and navigate to loby
      select = settings["select"]
      # send exception if !select and navigate to loby
      game = Connect4Game.find(select)
      # send exception if !game and navigate to loby

			move = tokens['column']
      # client_events = []

			data = game.move(visitor, move.to_i)
			return if data.nil?  #invalid move - send message to visitor
      
      cap.add_item('game-pieces', data)

      # ctx = {appName: app_name, screenName:'play-game', displayName:'game-pieces'}
      # event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      # client_events << event

      data = game.player1_for_display
      cap.show_data('player1', data)
      data = game.player2_for_display
      cap.show_data('player2', data)

      # cap.fire2game(game.channel_id)
      cap.fire2player(game.player1_visitor.wid)
      cap.fire2player(game.player2_visitor.wid)
      cap.clear_events
      # ctx = {appName: app_name, screenName:'play-game', displayName:'player1'}
			# data = game.player1_for_display
			# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
			# client_events << event
			# ctx = {appName: app_name, screenName:'play-game', displayName:'player2'}
			# data = game.player2_for_display
			# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
			# client_events << event
      # PusherChannels.instance.trigger_private_channel_event(game.channel_id, "fire-event", client_events)

      if(game.game_is_in_progress)
	    	puts "----game in progress!"	    	
      	visitor_to_act = game.player_visitor(game.player_to_act)
	    	puts "----to act: #{visitor_to_act.nickname}!"

        data = {status:"It's your turn!"}
        cap.show_data('game-status', data)
        cap.fire2player(visitor_to_act.wid)
        cap.clear_events
				# ctx = {appName: app_name, screenName:'play-game', displayName:'game-status'}
				# data = {status:"It's your turn!"}
				# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
	      # PusherChannels.instance.trigger_private_channel_event(visitor_to_act.wid, "fire-event", event)

      	other_visitor = game.other_player_visitor(game.player_to_act)
	    	puts "----other to act: #{other_visitor.nickname}!"	    	

        data = {status:"Waiting for #{visitor_to_act.nickname} to move..."}
        cap.show_data('game-status', data)
        cap.fire2player(other_visitor.wid)
        cap.clear_events

				# data = {status:"Waiting for #{visitor_to_act.nickname} to move..."}
				# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
	      # PusherChannels.instance.trigger_private_channel_event(other_visitor.wid, "fire-event", event)
	    else
	    	puts "----No game in progress!"	    	
      end


      if (game.winner>0)
	    	puts "----Winner is #{game.winner}!"
      	winning_visitor = game.player_visitor(game.winner)
	    	puts "----winner: #{winning_visitor.nickname}!"	    	

        data = {status:"You Won!"}
        cap.show_data('game-status', data)
        cap.fire2player(winning_visitor.wid)

				# ctx = {appName: app_name, screenName:'play-game', displayName:'game-status'}
				# data = {status:"You Won!"}
				# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
	      # PusherChannels.instance.trigger_private_channel_event(winning_visitor.wid, "fire-event", event)

      	other_visitor = game.other_player_visitor(game.winner)
	    	puts "----looser: #{other_visitor.nickname}!"	    	
        data = {status:"#{winning_visitor.nickname} has won!"}
        cap.show_data('game-status', data)
        cap.fire2player(other_visitor.wid)

				# data = {status:"#{winning_visitor.nickname} has won!"}
				# event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
	      # PusherChannels.instance.trigger_private_channel_event(other_visitor.wid, "fire-event", event)
	    else
	    	puts "----No Winner Yet!"
      end
	  end
	end
end