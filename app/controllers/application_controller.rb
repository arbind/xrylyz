class ApplicationController < ActionController::Base
  protect_from_forgery


  def self.on_unknown (tokens)
  	puts "UnKnown action!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  	puts tokens
  	puts "UnKnown action!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end


  def self.on_close_uid_channel (tokens)
  	uid_channel = "client-rylyz-#{tokens['uid']}"
    PusherChannels.stop_private_channel(uid_channel)
	end

  def self.on_open_app (tokens)
    # lookup the TargetController 
    app = tokens["app"] || "application"
		app = app.underscore.camelize + "Controller"
    c = Kernel.const_get(app)
    c::on_open(tokens)
  end

end
