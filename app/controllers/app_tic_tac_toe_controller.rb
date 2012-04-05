class AppTicTacToeController < RylyzAppController

  def self.on_load_data(visitor, tokens)
  end	


  class ScreenGameRoomController < RylyzScreenController

  	def self.on_change_me(visitor, tokens)

	  	p3 = {name: "Frankenstein"}

	  	ctx = {
	  		appName: 'TicTacToe',
	  		screenName: 'game-room',
	  		displayName: 'player2'
	  	}
	  	event = {
				queue:'app-server',
	  		context: ctx,
	  		type: 'load-data',
	  		data: p3,
	  	}

      PusherChannels.instance.trigger_private_channel_event(visitor.wid, "fire-event", event)
  	end

	  def self.on_load_data(visitor, tokens)
	  	events = []
	  	p1 = {name: "Tara"}
	  	p2 = {name: "Shakespear"}

	  	ctx = {
	  		appName: 'TicTacToe',
	  		screenName: 'game-room',
	  		displayName: 'player1'
	  	}
	  	event = {
				queue:'app-server',
	  		context: ctx,
	  		type: 'load-data',
	  		data: p1,
	  	}
	  	events << event

	  	ctx = {
	  		appName: 'TicTacToe',
	  		screenName: 'game-room',
	  		displayName: 'player2'
	  	}
	  	event = {
				queue:'app-server',
	  		context: ctx,
	  		type:'load-data',
	  		data: p2,
	  	}	  	
	  	events << event

      PusherChannels.instance.trigger_private_channel_event(visitor.wid, "fire-event", events)
	  end	

  end

end
