class RylyzAppController

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
    controller = Kernel.const_get(controller_name) rescue nil
  end

  def self.lookup_screen_controller(info)
    app_controller = lookup_app_controller(info)
    return nil if app_controller.nil?

    screen_name = lookup_property(info, "screenName")
    return nil if screen_name.nil?

    controller_name = "Screen#{screen_name.underscore.camelize}Controller"
    controller = app_controller.const_get(controller_name) rescue nil
  end

  def self.lookup_display_controller(info)
    screen_controller = lookup_screen_controller(info)
    return nil if screen_controller.nil?

    display_name = lookup_property(info, "displayName")
    return nil if display_name.nil?

    controller_name = "Display#{display_name.underscore.camelize}Controller"
    controller = screen_controller.const_get(controller_name) rescue nil
  end

  def self.lookup_controller (info)
    display_controller = lookup_display_controller(info)
    screen_controller = lookup_screen_controller(info)
    app_controller = lookup_app_controller(info)
    {
      app_controller: app_controller,
      screen_controller: screen_controller,
      display_controller: display_controller
    }
  end

  def self.on_unknown (visitor, tokens)
  	puts "UnKnown action!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  	puts tokens
  	puts "UnKnown action!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end

  def self.on_close_uid_channel (visitor, tokens) #+++ change wygyt uid channel to presence channel
  	# uid_channel = "client-rylyz-#{tokens['wid']}"
  	#  PusherChannels.stop_private_channel(uid_channel)
	end

  def self.on_open_app (visitor, tokens)
    # lookup the TargetController 
    app_name = lookup_property(tokens, "appName") || "wygyt"
		app_controller_name = "App#{app_name.underscore.camelize}Controller"

    wid = tokens['wid'] || tokens['uid']
    #app_name = tokens["app"]
    puts "OPENING #{app_name} FOR #{tokens}"
    app_display = render(app_name)

    c = Kernel.const_get(app_controller_name)
    aid = c::app_uid

    #+++ is it required to start a listener thread?
    PusherChannels.instance.start_private_channel(aid)

    # send a direct message(wid) to launch a new listener for the app(aid)
    # so we can send messages on it to ever widget listening
    # this is a 1-way channel - from app to wygyt
    # no need to bind listeners on the client side
    event = {
      launchChannel:aid,
      scope:'private',
      wid:wid
    }
   PusherChannels.instance.trigger_private_channel_event(wid, "launch-listener", event)

		# send a direct message(wid) to open this app
    ctx = {
      appName: app_name
    }
    event ={
      context: ctx,
      display:app_display
    }
    PusherChannels.instance.trigger_private_channel_event(wid, "open-app", event)
  end

  def self.materialize_message_capsule_for_all (event_type)
    ctx = {appName: app_name}
    RylyzMessageCapsule.new('app-server', event_type, ctx, app_uid)
  end

  def self.materialize_message_capsule_for_wid (event_type, wid)
    ctx = {appName: app_name}
    RylyzMessageCapsule.new('app-server', event_type, ctx, wid)
  end

end
