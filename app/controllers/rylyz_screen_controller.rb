class RylyzScreenController

  def self.app_name # app_name for AppChatController is 'chat'
    self.name.split("::").first.underscore.split('_')[1...-1].join("_") 
  end

  def self.screen_name # screen_name for AppChatController::ScreenChatRoomController is 'chat_room'
    # self.name.split("::").last.underscore.split('_')[1...-1].join("_")
    self.name.split("::").last.underscore.split('_')[1...-1].join("-")
  end

  def self.app_uid
    puts "App name: #{app_name}"
    PusherChannels.instance.channel_name_for_app(app_name)
  end

  def self.screen_uid
    PusherChannels.instance.channel_name_for_screen(screen_name)
  end

  def self.screen_uid
  	PusherChannels.instance.channel_name_for_screen(app_name, screen_name)
  end

  def self.on_unknown (visitor, tokens)
  	puts "UnKnown action!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  	puts tokens
  	puts "UnKnown action!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end

  def self.on_close_uid_channel (visitor, tokens) #+++ change wyjyt uid channel to presence channel
  	# wid = "client-rylyz-#{tokens['wid']}"
  	#  PusherChannels.stop_private_channel(wid)
	end

  def self.on_open_screen (visitor, tokens)
  #   wid = tokens['wid'] || tokens['uid']
  #   context = tokens['context']
  #   app_name = context["appName"]
  #   screen_name = context["screenName"]
  #   puts "OPENING #{screen_name} in #{app_name} FOR #{tokens}"
  #   app_display = render(app_name)

  #   c = Kernel.const_get(app)
  #   aid = c::app_uid
		# # send a direct message(wid) to open the app
  #   PusherChannels.instance.trigger_private_channel_event(wid, "open-app", {display:app_display})
		# # send a direct message(wid) to launch a new listener for the app(aid)
  #   PusherChannels.instance.trigger_private_channel_event(wid, "launch-listener", {launchChannel:aid, scope:'private', wid:wid})
		# # open a channel for this app(aid) so we can send messages on it to everyone listening
		# PusherChannels.instance.start_private_channel(aid)
		# # this is a 1-way channel - from app to wyjyt - so no need to bind listeners

  end

  def self.materialize_message_capsule_for_all (event_type)
    ctx = {appName: app_name, screenName: screen_name}
    RylyzMessageCapsule.new('app-server', event_type, ctx, app_uid)
  end

  def self.materialize_message_capsule_for_wid (event_type, wid)
    ctx = {appName: app_name, screenName: screen_name}
    RylyzMessageCapsule.new('app-server', event_type, ctx, wid)
  end

end
