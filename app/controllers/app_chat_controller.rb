class AppChatController < AppRylyzController

  # for the app channel: goes to anyone who has the app open
  # +++TOO: define broadcast event names for this app channel
  # +++TOO: define private events names for this app channel

  # ++TODO: for each screen: - goes to anyone who has the screen open
  # define all channels: with scope and name, and for each channel:
  # +++TODO: define broadcast event names for this app
  # +++TODO: define private events names for this app

  def self.on_load_data(tokens)
  end

  def self.on_data_input(tokens)

    ScreenChatRoomController::say_hi

    wid = tokens['uid']
    # +++TODO: map uid to user
    formMetadata = tokens['formData']
    inputDataSet = formMetadata['dataSet']
    messageInput = inputDataSet['message']
    message = messageInput['value']

    ctx = {app: app_name, screen:'chat-room', display:'messages'}
    data = { message:message }
    event  = {queue:'app-server', type:'add-item', context:ctx, data: data}

    puts "App uid: #{app_uid}"

    PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)
  end


  class ScreenSplashController < AppRylyzScreenController
    def self.on_load_data(tokens)
    end
  end

  class ScreenNickNameController < AppRylyzScreenController
    # update user on_data_input4nickname
    def self.on_data_input4message(tokens)
    end

    def self.on_load_data(tokens)
    end
  end

  class ScreenChatRoomController < AppRylyzScreenController

    def self.on_load_data(tokens)
    end

    def self.on_data_input(tokens)
      wid = tokens['uid']
      # +++TODO: map uid to user
      formMetadata = tokens['formData']
      inputDataSet = formMetadata['dataSet']
      messageInput = inputDataSet['message']
      message = messageInput['value']

      ctx = {appName: app_name, screenName:'chat-room', displayName:'messages'}
      data = { message:message }
      event  = {queue:'app-server', type:'add-item', context:ctx, data: data}
      puts "Screen::App uid: #{app_uid}"
      PusherChannels.instance.trigger_private_channel_event(app_uid, "fire-event", event)
    end

  end

  class ScreenRoomListController < AppRylyzScreenController

    def self.on_load_data(tokens)
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

    def self.on_data_input(tokens)
      wid = tokens['uid']
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