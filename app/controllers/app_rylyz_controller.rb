class AppRylyzController


  def self.app_name # app_name for AppChatController is 'chat'
    self.name.split("::").first.underscore.split('_')[1...-1].join("_") 
  end

  def self.app_uid
  	PusherChannels.instance.channel_name_for_app(app_name)
  end


  def self.render (app_name, view_name="app")
    template = File.read("#{Dir.pwd}/app/displays/#{app_name}/#{view_name}.html.haml")
    haml_engine = Haml::Engine.new(template)
    output = haml_engine.render
  end

  def self.on_unknown (tokens)
  	puts "UnKnown action!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  	puts tokens
  	puts "UnKnown action!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end

  def self.on_close_uid_channel (tokens) #+++ change wyjyt uid channel to presence channel
  	# uid_channel = "client-rylyz-#{tokens['uid']}"
  	#  PusherChannels.stop_private_channel(uid_channel)
	end

  def self.on_open_app (tokens)
    # lookup the TargetController 
    app = tokens["app"] || "wyjyt"
		app = "App#{app.underscore.camelize}Controller"

    wid = tokens['uid']
    app_name = tokens["app"]
    puts "OPENING #{app_name} FOR #{tokens}"
    app_display = render(app_name)

    c = Kernel.const_get(app)
    aid = c::app_uid
		# send a direct message(wid) to open the app
    PusherChannels.instance.trigger_private_channel_event(wid, "open-app", {display:app_display})
		# send a direct message(wid) to launch a new listener for the app(aid)
    PusherChannels.instance.trigger_private_channel_event(wid, "launch-listener", {launchChannel:aid, scope:'private', wid:wid})
		# open a channel for this app(aid) so we can send messages on it to everyone listening
		PusherChannels.instance.start_private_channel(aid)
		# this is a 1-way channel - from app to wyjyt - so no need to bind listeners

  end

end
