class AppChatController < RylyzAppController

  # for the app channel: goes to anyone who has the app open
  # +++TOO: define broadcast event names for this app channel
  # +++TOO: define private events names for this app channel

  # ++TODO: for each screen: - goes to anyone who has the screen open
  # define all channels: with scope and name, and for each channel:
  # +++TODO: define broadcast event names for this app
  # +++TODO: define private events names for this app

  def self.on_load_data(visitor, tokens)
  end

  # def self.on_data_input(visitor, tokens)

  #   ScreenChatRoomController::say_hi

  #   wid = tokens['wid'] || tokens['uid']
  #   # +++TODO: map uid to user
  #   formMetadata = tokens['formData']
  #   inputDataSet = formMetadata['dataSet']
  #   messageInput = inputDataSet['message']
  #   message = messageInput['value']

  #   ctx = {app: app_name, screen:'chat-room', display:'messages'}
  #   data = { message:message }
  #   event  = {queue:'app-server', type:'add-item', context:ctx, data: data}

  #   puts "App uid: #{app_uid}"

  #   PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)
  # end

  class ScreenSplashController < RylyzScreenController
    def self.on_load_data(visitor, tokens)
    end
  end

  class ScreenInputNicknameController < RylyzScreenController
    # update user on_data_input4nickname
    def self.on_data_input(visitor, tokens)
      wid = tokens['wid']

      # +++TODO: map uid to user
      formMetadata = tokens['formData']
      inputDataSet = formMetadata['dataSet']
      nicknameInput = inputDataSet['nickname']
      nickname = nicknameInput['value']
      visitor.nickname = nickname

      event  = {queue:'app-server', type:'update-me', data: visitor.for_display}
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", event)

      ctx = {appName: app_name}
      event  = {queue:'screen', type:'navigation', nextScreen:'lobby', context:ctx }
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", event)

    end

    def self.on_load_data(visitor, tokens)
    end
  end

  class ScreenChatRoomController < RylyzScreenController

    def self.on_load_data(visitor, tokens)
      wid = tokens['wid'] || tokens['uid']

      settings = tokens["settings"]
      select = settings["select"]
      chat_room = ChatRoom.find(select)
      ctx = {appName: app_name, screenName:'chat-room'}
      event  = {queue:'app-server', type:'load-data', context:ctx, data: ''}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

      #+++ is it required to start a listener thread?
      #PusherChannels.instance.start_private_channel(chat_room.channel_id)
      # this is a 1-way channel - from app to wygyt - so no need to bind listeners
      PusherChannels.instance.trigger_private_channel_event(wid, "launch-listener", {launchChannel:chat_room.channel_id, scope:'private', wid:wid})

      ctx = {appName: app_name, screenName:'chat-room', displayName:'messages'}
      name = visitor.nickname || 'person'
      data = { message:"#{visitor.nickname} just joined the room!" }
      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)
      
      data = chat_room.visitors_for_display
      ctx = {appName: app_name, screenName:'chat-room', displayName:'people'}
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)

      chat_room.add_visitor visitor

      data = visitor.for_display
      ctx = {appName: app_name, screenName:'chat-room', displayName:'people'}
      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)
    end

    def self.on_data_input(visitor, tokens)
      wid = tokens['wid'] || tokens['uid']
      # lookup the chat room:
      settings = tokens['settings']
      select = settings['select']
      chat_room = ChatRoom.find(select)

      # +++TODO: map uid to user
      formMetadata = tokens['formData']
      inputDataSet = formMetadata['dataSet']
      messageInput = inputDataSet['message']
      message = messageInput['value']

      ctx = {appName: app_name, screenName:'chat-room', displayName:'messages'}
      data = { message:message }
      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)
    end

  end

  class ScreenLobbyController < RylyzScreenController

    def self.on_load_data(visitor, tokens)
      ctx = {appName: app_name, screenName:'lobby'}
      data = {num_rooms: ChatRoom.all.count }
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

      ctx = {appName: app_name, screenName:'lobby', displayName:'rooms'}
      data = ChatRoom.all.collect{|chat_room| chat_room.for_display }
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)
    end

    def self.on_data_input(visitor, tokens)
      wid = tokens['wid'] || tokens['uid']
      # +++TODO: map uid to user
      formMetadata = tokens['formData']
      inputDataSet = formMetadata['dataSet']
      messageInput = inputDataSet['newRoomName']
      name = messageInput['value']
      newRoom = ChatRoom.create({name: name})

      ctx = {appName: app_name, screenName:'lobby', displayName:'rooms'}
      data = newRoom.for_display
      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

      settings = {select: newRoom.id.to_s}
      event  = {queue:'screen', type:'navigation', nextScreen:'chat-room', context:ctx, settings: settings }
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", event)
    end

  end

end