require 'singleton'
require 'httparty'
require 'pusher-client'
require 'active_support/inflector'

RYLYZ_PLAYER_HOST = Socket::gethostname rescue "localhost"
RYLYZ_PLAYER_HOST = "#{ENV["HEROKU_APP_NAME"]}.herokuapp.com" unless ENV["HEROKU_APP_NAME"].nil?
puts "RYLYZ_PLAYER_HOST = #{RYLYZ_PLAYER_HOST}"

NoOBJECT = {}

#+++TODO: store all channel related data in redis

APP_CHANNELS = {}
SCREEN_CHANNELS = {}
OBJECT_CHANNELS = {}

# VISITORS_AUTHENTICATING = {}
VISITORS = {} # lookup visitor by id temporary memory storage! 
VISITORS_WIDS = {} # lookup visior by wid
VISITORS_SOCKETS = {} # lookup visior by socket_id

class Visitor

  attr_accessor :id, :wid, :socket_id, :nickname, :source_url

  def initialize
    self.id = SecureRandom.uuid
    VISITORS[id] = self  # make this visitor available by id
  end

  def for_display
    {
      id: id,
      nickname: nickname,
      source_url: source_url
    }
  end

end

# class Member
#   attr_accessor :id, :name, :email, :nickname
#   #attr_reader :my_readable_property
#   #attr_writer :my_writable_property
# end

# class Player
#   attr_accessor :id, :visitor
# end

# class Club
#   attr_accessor :id, :channel_name, :visitors, :sub_clubs
# end

# class AppClub < Club
# end

# class GameClub < Club
# end

# class ChatClub < Club
# end


Pusher.app_id = RylyzPlayer::Application.config.pusher_app_id
Pusher.key    = RylyzPlayer::Application.config.pusher_key
Pusher.secret = RylyzPlayer::Application.config.pusher_secret

PusherClient.logger = Logger.new(STDOUT)

class PusherChannels
  include Singleton

  def initialize
    @channels = {
      :public => {},
      :private => {},
      :presence => {}
    }
    db_populate_channels
  end

  # !!!! begin
  # to isolate a listener to this server only: add a hostname to the channel name:
  # adding hostname to end of a channel name will ensure that listeners run only on 1 machine
  # be aware that in order to communicate to this server's listener:
  # the javascript clients must also add this same hostname to its channels 
  # Revist this approach when re-architecting for scaleability having multiple servers.
  # !!!! end
  def materialize_channel_name(scope, channel_name)
    "#{scope.to_s}-rylyz-#{channel_name}-#{RYLYZ_PLAYER_HOST}"
  end

  def channel_name_for_app(app_name)
    channel_name = APP_CHANNELS[app_name]
    return channel_name unless channel_name.nil?
    rand = SecureRandom.uuid
    stamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    APP_CHANNELS[app_name] = "#{rand}-#{stamp}"
  end

  def channel_name_for_screen(app_name, screen_name)
    key = "#{app_name}.#{screen_name}"
    channel_name = SCREEN_CHANNELS[key]
    return channel_name unless channel_name.nil
    rand = SecureRandom.uuid
    stamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    SCREEN_CHANNELS[key] = "#{rand}-#{stamp}"
  end

  def channel_name_for_class_id(classz, id)
    key = "#{classz.name}.#{id}"
    channel_name = OBJECT_CHANNELS[key]
    return channel_name unless channel_name.nil?
    rand = SecureRandom.uuid
    stamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    OBJECT_CHANNELS[key] = "#{rand}-#{stamp}"
  end

  def trigger_public_channel_event(channel_name, event_name, tokens)
    trigger_channel_event(:public, channel_name, event_name, tokens)
  end
  def trigger_private_channel_event(channel_name, event_name, tokens)
    trigger_channel_event(:private, channel_name, event_name, tokens)
  end
  def trigger_presence_channel_event(channel_name, event_name, tokens)
    trigger_channel_event(:presence, channel_name, event_name, tokens)
  end
  def trigger_channel_event(scope, channel_name, event_name, tokens)
    scoped_channel_name = materialize_channel_name(scope, channel_name)
    puts "Sending #{event_name} on #{scoped_channel_name}"
    Pusher[scoped_channel_name].trigger(event_name, tokens.to_json )
  end

  def on_public_channel_event(channel_name, event_name, &block)
    public_event_name = "rylyz-#{event_name}"
    PusherChannels.instance.on_channel_event(:public, channel_name, public_event_name, block)
  end
  def on_private_channel_event(channel_name, event_name, &block)
    private_event_name = "client-rylyz-#{event_name}"
    PusherChannels.instance.on_channel_event(:private, channel_name, private_event_name, block)
  end
  def on_presence_channel_event(channel_name, event_name, &block)
    presence_event_name = "client-rylyz-#{event_name}"
    PusherChannels.instance.on_channel_event(:presence, channel_name, presence_event_name, block)
  end
  def on_channel_event(scope, channel_name, scoped_event_name, handler)
    channel_socket(scope, channel_name).bind(scoped_event_name) do |data|
      begin #safeguard the handler block
        handler.call( data )
      rescue RuntimeError => e
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        puts "-----  Runtime Exception! #{e}"
        puts "Ehen handling event: #{scoped_event_name}  scope: #{scope}  channel: #{channel_name}"
        puts e.backtrace
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        #+++ Report exception back to widget (Trigger on scope channel_name)
      rescue Exception => e
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        puts "----- Exception! #{e}"
        puts "Ehen handling event: #{scoped_event_name}  scope: #{scope}  channel: #{channel_name}"
        puts e.backtrace
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        #+++ Report exception back to widget (Trigger on scope channel_name)
      else
        # Do this if no exception was raised
      ensure
        # Do this whether or not an exception was raised
      end
    end
  end

  def public_socket(channel_name)   channel_socket(:public, channel_name)   end
  def private_socket(channel_name)  channel_socket(:private, channel_name)  end
  def presence_socket(channel_name) channel_socket(:presence, channel_name) end
  def channel_socket(scope, channel_name)
    listener_thread = listener_thread_for_channel(scope, channel_name)
    s = nil
    s = listener_thread[:socket] if listener_thread
  end

  def stop_public_channel(channel_name)   stop_channel(:public, channel_name)   end
  def stop_private_channel(channel_name)  stop_channel(:private, channel_name)  end
  def stop_presence_channel(channel_name) stop_channel(:presence, channel_name) end
  def stop_channel(scope, channel_name)
    channel = @channels[scope][channel_name]
    Pusher[scoped_channel_name].trigger("started-listening", {}.to_json )

    return if not channel
    #+++TODO turn off the socket and end the thread.
  end

  def start_public_channel(channel_name, handlers=nil)   start_channel(:public, channel_name, handlers)   end
  def start_private_channel(channel_name, handlers=nil)  start_channel(:private, channel_name, handlers)  end
  def start_presence_channel(channel_name, handlers=nil) start_channel(:presence, channel_name, handlers) end
  def start_channel(scope, channel_name, handlers=nil)
    Thread::exclusive {
      @channels[scope][channel_name] = listener_thread_for_channel(scope, channel_name)
    }
    return @channels[scope][channel_name] if handlers.nil?

    handlers.each do |event_name, handler_blk|
      on_channel_event(scope, channel_name, event_name, handler_blk)
    end
    @channels[scope][channel_name]
  end

  def listener_thread_for_channel(scope, channel_name)
    return @channels[scope][channel_name] if @channels[scope][channel_name]
    scoped_channel_name = materialize_channel_name(scope, channel_name)
    listener_thread = Thread.new do
          puts "-------o #{scoped_channel_name} Thread Starting"
          Thread.current[:connected] = false
          Thread.current[scope] = true
          Thread.current[:name] = scoped_channel_name
          Thread.current[:start_time] = Time.now()
          Thread.current[:last_heartbeat] = nil

          options = {:secret => Pusher.secret}
          socket = PusherClient::Socket.new(Pusher.key, options)

          socket.subscribe(scoped_channel_name, "USER_ID")
          s = scope
          c = channel_name
          socket.bind('pusher:connection_established') do |data|
            Thread.current[:connected] = true
            PusherChannels.instance.trigger_channel_event(scope, channel_name, "started-listening", {}.to_json)
          end

        # socket.bind('pusher_internal:member_removed') do |data|
        #   puts "-------x Unsubscribed! #{data}"
            # can add another listener to stop this listener if needed on this event
            # just check it if it was a single private channel, or if there are no more users, or etc...
            # {
            #   "event": "pusher_internal:member_removed",
            #   "channel": "presence-example-channel",
            #   "data": {
            #     "user_id": String,
            #   }
            # }
        # end

          socket.bind('pusher:heartbeat') do |data|
            Thread.current[:last_heartbeat] = Time.now()
          end
          Thread.current[:socket] = socket

          socket.connect # thread goes to sleep and waits for channel events
        end
    @channels[scope][channel_name] = listener_thread        
    sleep 0.1 while 'sleep'!=listener_thread.status #sleep main thread until listner_thread has started and is listening (in sleep mode)
    puts "-------x #{scoped_channel_name} Thread Launched"
    listener_thread
  end

  private
  #+++ TODO synch channels and handlers in case server needs to be restarted

  def db_populate_channels
    #+++TODO load saved channels from DB in case of server restart
  end

  def db_save_channel
    #+++TODO save to DB in case of server crash
  end
  def db_delete_channel
    #+++TODO delete from DB: in case of server crash
  end
  def db_save_event_handler
    #+++TODO save to DB in case of server crash
  end
  def db_delete_event_handler
    #+++TODO delete from DB:in case of server crash
  end

end

puts "=========================================="
puts "Pusher using #{ENV['RAILS_ENV']} mode settings"
puts "Pusher app_id => #{RylyzPlayer::Application.config.pusher_app_id}"
puts "Pusher key    => #{RylyzPlayer::Application.config.pusher_key}"
puts "=========================================="

# See: http://pusher.com/docs/pusher_protocol
# handlers = {
#  "pusher:heartbeat" => {},
#  "pusher:connection_established" => {},
#  "pusher:error" => {},  # "data": { "message": String, "code": Integer }
# }

# PusherChannels.instance.on_private_channel_event("wyjyt", "start-wyjyt") do |data|
#    local_response = HTTParty.get('http://127.0.0.1:8000/pusher/test', :query => {:data => data})
# end

PusherChannels.instance.start_private_channel("wyjyt")
PusherChannels.instance.on_private_channel_event("wyjyt", "open-wid-channel") do |data|
  tokens = JSON.parse(data)

  wid = tokens["wid"]
  url = tokens["url"]
  socket_id = tokens["pusher_socket_id"]

  visitor = VISITORS_SOCKETS[socket_id]
  visitor.wid = wid
  visitor.source_url = url
  VISITORS_WIDS[wid] = visitor # make visitor available by wid lookup
  PusherChannels.instance.trigger_private_channel_event(wid, "update-me", visitor.for_display)


  PusherChannels.instance.start_private_channel(wid)
  PusherChannels.instance.on_private_channel_event(wid, "event") do |data|
    visitor = VISITORS_WIDS[wid]
    tokens = nil
    begin
      # lookup the TargetController 
      tokens = JSON.parse(data)
      # context = tokens["context"] || NoOBJECT
      # appName = context["appName"] || "rylyz"
      # appController = "App#{appName.underscore.camelize}Controller"

      # screenName = context["screenName"] || nil
      # screenController = "Screen#{screenName.underscore.camelize}Controller" unless screenName.nil?

      #lookup the method to call
    rescue Exception => e
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      puts "WID Channel Exception for #{target_controller}.#{action}"
      puts "Could not read data in to json"
      puts "data: #{data}"
      puts "Exception: #{e}"
      puts e.backtrace
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      ev = {
        exception: e.to_s
      }
      PusherChannels.instance.trigger_private_channel_event(wid, 'server-side-exception', ev)
    ensure
      tokens = tokens || {}
    end
    begin #safeguard the handler block
      target_controller = AppRylyzController::lookup_controller(tokens) || AppRylyzController
      action = tokens["action"] || "unknown"
      action = "on_" + action.underscore
      target_controller.send(action, visitor, tokens)
    rescue RuntimeError => e
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      puts "WID Channel Runtime Exception invoking #{target_controller}.#{action}"
      puts "tokens: #{tokens}"
      puts "Exception: #{e}"
      puts e.backtrace
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      #+++TODO make this a convenience function: to trigger exceptions back 
      ev = {
        exception: e.to_s
      }
      PusherChannels.instance.trigger_private_channel_event(wid, 'server-side-exception', ev)
    rescue Exception => e
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      puts "WID Channel Exception invoking #{target_controller}.#{action}"
      puts "tokens: #{tokens}"
      puts "Exception: #{e}"
      puts e.backtrace
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      ev = {
        exception: e.to_s
      }
      PusherChannels.instance.trigger_private_channel_event(wid, 'server-side-exception', ev)
    else
      # Do this if no exception was raised
    ensure
      # Do this whether or not an exception was raised    
    end
  end
end


# PusherChannels.instance.start_private_channel("app-service")
# PusherChannels.instance.on_private_channel_event("app-service", "start-app") do |data|
#   tokens = JSON.parse(params[:data])
#   app_name = tokens["app_name"]
#   # on_events - start channel_set
# end

# PusherChannels.instance.on_private_channel_event("wyjyt", 'text-event') do |data|
#   puts "==== #{data} ===="
# end
