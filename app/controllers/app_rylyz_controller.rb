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


  def self.lookup_property(info, property_name)
    if(info.nil?); raise "Can not look up #{property_name}: info given is nil!" end

    value = nil
    ctx = info["context"] || nil
    value = (ctx[property_name] || nil) unless ctx.nil?
    value = (info[property_name] || nil) if value.nil?
    value
  end

  def self.lookup_app_controller (info)
    app_name = lookup_property(info, "appName")
    return nil if app_name.nil?

    controller_name = "App#{app_name.underscore.camelize}Controller"
    begin
      controller = Kernel.const_get(controller_name)
    rescue
      controller = nil
    end
    controller
  end

  def self.lookup_screen_controller(info)
    app_controller = lookup_app_controller(info)
    return nil if app_controller.nil?

    screen_name = lookup_property(info, "screenName")
    return nil if screen_name.nil?

    controller_name = "Screen#{screen_name.underscore.camelize}Controller"
    begin
      controller = app_controller.const_get(controller_name)
    rescue
      controller = nil
    end
    controller
  end

  def self.lookup_display_controller(info)
    screen_controller = lookup_screen_controller(info)
    return nil if screen_controller.nil?

    display_name = lookup_property(info, "displayName")
    return nil if display_name.nil?

    controller_name = "Display#{display_name.underscore.camelize}Controller"

    begin
      controller = screen_controller.const_get(controller_name)
    rescue
      controller = nil
    end
    controller
  end

  def self.lookup_controller (info)
    display_name = lookup_property(info, "displayName")
    if not display_name.nil?
      display_controller = lookup_display_controller(info)
      return display_controller unless display_controller.nil?
    end 

    screen_name = lookup_property(info, "screenName")
    if not screen_name.nil?
      screen_controller = lookup_screen_controller(info)
      return screen_controller unless screen_controller.nil?
    end 

    app_controller = lookup_app_controller(info)
    return app_controller unless app_controller.nil?

    return AppRylyzController # default
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

    #+++ is it required to start a listener thread?
    PusherChannels.instance.start_private_channel(aid)
    # this is a 1-way channel - from app to wyjyt - so no need to bind listeners
    PusherChannels.instance.trigger_private_channel_event(wid, "launch-listener", {launchChannel:aid, scope:'private', wid:wid})
    # open a channel for this app(aid) so we can send messages on it to everyone listening

		# send a direct message(wid) to open the app
    PusherChannels.instance.trigger_private_channel_event(wid, "open-app", {display:app_display})
		# send a direct message(wid) to launch a new listener for the app(aid)
  end

end
