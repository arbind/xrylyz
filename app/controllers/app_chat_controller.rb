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

  class ScreenNicknameController < RylyzScreenController
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
      event  = {queue:'screen', type:'navigation', nextScreen:'room-list', context:ctx }
      PusherChannels.instance.trigger_private_channel_event(wid, "fire-event", event)

    end

    def self.on_load_data(visitor, tokens)
      puts "--------- Load Data"
      puts tokens
      puts "--------- Load Data"
    end
  end

  class ScreenChatRoomController < RylyzScreenController

    def self.on_load_data(visitor, tokens)
      wid = tokens['wid'] || tokens['uid']

      settings = tokens["settings"]
      select = settings["select"]
      chat_room = ChatRoom.find(select)
      puts "%%%%%%%%%%%%%%%%%"
      puts "found #{chat_room.name} with #{chat_room.num_visitors} visitors"
      puts "%%%%%%%%%%%%%%%%%"
      ctx = {appName: app_name, screenName:'chat-room'}
      event  = {queue:'app-server', type:'load-data', context:ctx, data: ''}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

      #+++ is it required to start a listener thread?
      #PusherChannels.instance.start_private_channel(chat_room.channel_id)
      # this is a 1-way channel - from app to wyjyt - so no need to bind listeners
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

      puts "%%%%%%%%%%%%%%%%%"
      puts "Before room #{chat_room.name} has #{chat_room.num_visitors} visitors"
      puts "%%%%%%%%%%%%%%%%%"
      chat_room.add_visitor visitor
      puts "%%%%%%%%%%%%%%%%%"
      puts "After room #{chat_room.name} has #{chat_room.num_visitors} visitors"
      puts "%%%%%%%%%%%%%%%%%"

      data = visitor.for_display
      ctx = {appName: app_name, screenName:'chat-room', displayName:'people'}
      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)
    end

    def self.on_data_input(visitor, tokens)
      puts "============="
      puts tokens
      puts "============="
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
      puts "Screen::App uid: #{app_uid}"
      PusherChannels.instance.trigger_private_channel_event(chat_room.channel_id, "fire-event", event)
    end

  end

  class ScreenRoomListController < RylyzScreenController

    def self.on_load_data(visitor, tokens)
      ctx = {appName: app_name, screenName:'room-list'}
      data = {num_rooms: ChatRoom.all.count }
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)

      ctx = {appName: app_name, screenName:'chat-room', displayName:'rooms'}
      #+++TODO!!!!! this screen is the room-list screen this should not work wiht screenName=chat-room!
      #+++find out what's up with the references in the client side that it finds this and renders it!
      data = ChatRoom.all.collect{|chat_room| chat_room.for_display }
      event  = {queue:'app-server', type:'load-data', context:ctx, data: data}
      puts "Screen::App uid: #{app_uid}"
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

      ctx = {appName: app_name, screenName:'room-list', displayName:'rooms'}
      data = newRoom.for_display
      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)
    end

  end

end