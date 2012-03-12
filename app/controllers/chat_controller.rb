class ChatController


  def self.render (filename="app")
    app_name = "chat"
    view_name = filename
    template = File.read("#{Dir.pwd}/app/views/#{app_name}/#{view_name}.html.haml")
    haml_engine = Haml::Engine.new(template)
    output = haml_engine.render
  end

  def self.on_open(tokens)
    uid = tokens['uid']
    puts "OPENING CHAT FOR #{tokens}"
    app_display = render
    puts app_display
    PusherChannels.instance.trigger_private_channel_event(uid, "open-app", {display:app_display})
  end
end
