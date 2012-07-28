require 'singleton'
require 'httparty'
require 'pusher-client'
require 'active_support/inflector'


# +++TOOD detect when wid is no longer connected:
# 1. scan threads and collect the ones time of last send or receive > 5 seconds
# 2. ping the wids of the collected threads, setting a timer to check for a pong
# 3. if wid does not pong by the time the timer comes back, that thread may be disconnected
# Alternatively: Use a presence channel with the callbacks for Unsubscribe

puts "RYLYZ_PLAYER_HOST = #{RYLYZ_PLAYER_HOST}"

NoOBJECT = {}

#+++TODO: store all channel related data in redis

APP_CHANNELS = {}
SCREEN_CHANNELS = {}
OBJECT_CHANNELS = {}

# VISITORS_AUTHENTICATING = {}
VISITORS = {} # lookup visitor by id temporary memory storage!
VISITOR_WIDS = {} # lookup visior by wid
VISITOR_SOCKETS = {} # lookup visior by socket_id

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


Pusher.app_id = SECRETS[:PUSHER][:APP_ID]
Pusher.key    = SECRETS[:PUSHER][:KEY]
Pusher.secret = SECRETS[:PUSHER][:SECRET]

PusherClient.logger = Logger.new(STDOUT)

class PusherChannels
  include Singleton

  @pusher_socket = nil
  @pusher_listener_thread = nil

  # @@socket_logger = Logger.new('soceket_logger1')
  @@socket_logger = Logger.new(STDOUT)

  def self.socket_logger
    @@socket_logger
  end
  
  attr_reader :channels

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
    puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{scoped_channel_name}] #{event_name}"
    Pusher[scoped_channel_name].trigger(event_name, tokens.to_json )
    PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent #{event_name} [#{scope}-#{channel_name}]"
    PusherChannels::socket_logger.info "<--------------------------- #{tokens.to_json}]"
  end

  def on_public_channel_event(channel_name, event_name, &block)
    public_event_name = "rylyz-#{event_name}"
    PusherChannels.instance.bind_channel_event_handler(:public, channel_name, public_event_name, block)
  end
  def on_private_channel_event(channel_name, event_name, &block)
    private_event_name = "client-rylyz-#{event_name}"
    PusherChannels.instance.bind_channel_event_handler(:private, channel_name, private_event_name, block)
  end
  def on_presence_channel_event(channel_name, event_name, &block)
    presence_event_name = "client-rylyz-#{event_name}"
    PusherChannels.instance.bind_channel_event_handler(:presence, channel_name, presence_event_name, block)
  end
  def bind_channel_event_handler(scope, channel_name, scoped_event_name, handler)
    raise "Not connected to Pusher!" if @pusher_socket.nil?
    scoped_channel_name = materialize_channel_name(scope, channel_name)

    channel = @pusher_socket.channels[scoped_channel_name]
    raise "Not subscribed to #{scope}: #{scoped_channel_name}! Can not bind event handler or #{scoped_event_name}" if channel.nil?

    channel.bind(scoped_event_name) do |data| # +++ *** getting error on this line when channel_socket is nil for some reason?
    PusherChannels::socket_logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> Got #{scoped_event_name} on #{scope}-#{channel_name}"
    PusherChannels::socket_logger.info "> #{data}"
      begin #safeguard the handler block
        handler.call( data )
      rescue RuntimeError => e
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        puts "-----  Runtime Exception! #{e}"
        puts "When handling event: #{scoped_event_name}  scope: #{scope}  channel: #{channel_name}"
        puts "data: #{data}"
        puts e.backtrace
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        #+++ Report exception back to widget (Trigger on scope channel_name)
      rescue Exception => e
        puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        puts "----- Exception! #{e}"
        puts "When handling event: #{scoped_event_name}  scope: #{scope}  channel: #{channel_name}"
        puts "data: #{data}"
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

  # def public_socket(channel_name)   channel_socket(:public, channel_name)   end
  # def private_socket(channel_name)  channel_socket(:private, channel_name)  end
  # def presence_socket(channel_name) channel_socket(:presence, channel_name) end
  # def channel_socket(scope, channel_name)
  #   # listener_thread = subscribe_to_channel(scope, channel_name)
  #   # s = nil
  #   # s = listener_thread[:socket] if listener_thread
  #   s = nil
  #   s = @listener_thr[:socket] if @listener_thr
  #   s
  # end

  def stop_public_channel(channel_name)   stop_channel(:public, channel_name)   end
  def stop_private_channel(channel_name)  stop_channel(:private, channel_name)  end
  def stop_presence_channel(channel_name) stop_channel(:presence, channel_name) end
  def stop_channel(scope, channel_name)
    scoped_channel_name = materialize_channel_name(scope, channel_name)
    puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{scoped_channel_name}] stopped-listening"
    Pusher[scoped_channel_name].trigger("stopped-listening", {}.to_json )
    PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent stopped-listening [#{scope}-#{channel_name}]"

    if @listener_thr
      socket = @listener_thr[:socket]
      socket.unsubscribe(scoped_channel_name)
    end
  end

  def start_public_channel(channel_name, handlers=nil)   start_channel(:public, channel_name, handlers)   end
  def start_private_channel(channel_name, handlers=nil)  start_channel(:private, channel_name, handlers)  end
  def start_presence_channel(channel_name, handlers=nil) start_channel(:presence, channel_name, handlers) end
  def start_channel(scope, channel_name, handlers=nil)
    puts "o--- start_channel with scope: #{scope} for channel_name: #{channel_name}"
    channel = subscribe_to_channel(scope, channel_name)
    return if handlers.nil?

    puts "o--- binding #{handlers.count} handlers to channel #{scope}:#{channel_name} for event:#{event_name}"
    handlers.each do |event_name, handler_blk|
      bind_channel_event_handler(scope, channel_name, event_name, handler_blk)
    end
    nil
  end

  def subscribe_to_channel(scope, channel_name, user_id=RYLYZ_PLAYER_HOST)
    scoped_channel_name = materialize_channel_name(scope, channel_name)
    channel = @pusher_socket.subscribe(scoped_channel_name, user_id)
    if (channel.subscribed)
      PusherChannels.instance.trigger_channel_event(scope, channel_name, "started-listening", {}.to_json)
      puts  "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent started-listening [#{scope}-#{channel_name}]"
      PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent started-listening [#{scope}-#{channel_name}]"
    end
    channel
  end

  def connect(&on_connection_established)
    return unless @pusher_listener_thread.nil?

    begin # create a new socket and subscribe to channel  
      @pusher_listener_thread = Thread.new do
        puts "o-------- Pusher Thread: Started"

        Thread.current[:name]           = "Pusher Listener"
        Thread.current[:start_time]     = Time.now()
        Thread.current[:pusher_socket]         = nil
        Thread.current[:pusher_connected]      = false
        Thread.current[:pusher_last_heartbeat] = nil

        @pusher_socket = open_socket(on_connection_established)

        @pusher_socket.connect unless @pusher_socket.nil? # thread goes to sleep and waits for channel events
        puts "!-------- Pusher Thread: NO LONGER LISTENING TO PUSHER CHANNEL EVENTS"
      end
      puts "o-------- Pusher Thread: Listener Launched and Runing"
    rescue Exception => e
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      puts "!!! Could not launch Pusher listener thread."
      puts "----- Exception! #{e}"
      puts e.backtrace
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    end
    @pusher_listener_thread
  end

  def open_socket(on_connection_established)
    begin
      puts "o-------- Pusher Socket: opening connection"
      socket = PusherClient::Socket.new(Pusher.key, {:secret => Pusher.secret} )

      socket.bind('pusher:connection_established') do |data|
        puts "o-------- Pusher Socket: connected"
        on_connection_established.call(socket)
      end

      socket.bind('pusher:connection_failed') do |data|
        puts "!-------- Pusher Socket: FAILED TO CONNECT"
      end

      socket .bind('pusher:heartbeat') do |data|
        Thread.current[:last_heartbeat] = Time.now()
      end

      socket
    rescue Exception => e
      puts "!!! Pusher Soceket: CAN NOT CREATE A NEW PUSHER SOCKET."
      puts "Are you running in production without the key?"
      puts e.message
      puts "Exception: #{e}"
      puts e.backtrace
      nil
    end
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

# See: http://pusher.com/docs/pusher_protocol
# handlers = {
#  "pusher:heartbeat" => {},
#  "pusher:connection_established" => {},
#  "pusher:error" => {},  # "data": { "message": String, "code": Integer }
# }

# PusherChannels.instance.on_private_channel_event("wygyt", "start-wygyt") do |data|
#    local_response = HTTParty.get('http://127.0.0.1:8000/pusher/test', :query => {:data => data})
# end


def start_realtime_sockets
  return true if ("on" == ENV['REAL_TIME'].to_s.downcase)
  return false if ("off" == ENV['REAL_TIME'].to_s.downcase)
  return false if ("assets" == ENV['RAILS_GROUPS'].to_s.downcase)
  return false if defined?(Rails::Console)
  return true
end

unless start_realtime_sockets
  puts "=========================================="
  puts "Pusher using #{ENV['RAILS_ENV']} mode settings"
  puts "Pusher app_id => #{SECRETS[:PUSHER][:APP_ID]}"
  puts "Pusher key    => #{SECRETS[:PUSHER][:KEY]}"
  puts "=========================================="
end


puts "CONSOLE IS RUNNING" if defined?(Rails::Console)
puts "RAILS_GROUPS = #{ENV['RAILS_GROUPS']}" if ENV['RAILS_GROUPS']
if not start_realtime_sockets
  puts "REALTIME SOCKETS ARE OFF"
else
  puts "REAL_TIME = ON"
  PusherChannels.instance.connect do |socket|
    PusherChannels.instance.start_private_channel("wygyt")
    PusherChannels.instance.on_private_channel_event("wygyt", "open-wid-channel") do |data|
      tokens = JSON.parse(data)

      wid = tokens["wid"]
      url = tokens["url"]
      socket_id = tokens["pusher_socket_id"]

      visitor = VISITOR_SOCKETS[socket_id]
      visitor.wid = wid  #+++ *** sometimes getting nil for visitor here - did not auth properly?
      visitor.source_url = url
      VISITOR_WIDS[wid] = visitor # make visitor available by wid lookup
      puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#wid}] update-me"
      PusherChannels.instance.trigger_private_channel_event(wid, "update-me", visitor.for_display)
      PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent update-me [#{wid}] (on wid)]"

      PusherChannels.instance.start_private_channel(wid)
      PusherChannels.instance.on_private_channel_event(wid, "event") do |data|
        visitor = VISITOR_WIDS[wid]
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
          puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{wid}] server-side-exception"
          PusherChannels.instance.trigger_private_channel_event(wid, 'server-side-exception', ev)
          PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent server-side-exception [#{wid} (on wid)]"
        ensure
          tokens = tokens || {}
        end
        begin #safeguard the handler block

          controllers = RylyzAppController::lookup_controller(tokens)
          action = tokens["action"] || "action_is_unknown"

          #for hi events, the event type will specify the handler
          if ("hi" == action); action = tokens["type"] || "type_is_unknown" end

          PusherChannels::socket_logger.info " wid[#{wid}] event: #{action}"

          action = "on_#{action.underscore}"  # e.g "on_load_data" or "on_start_new_game"

          target_controller = nil

          ctrlr = controllers[:display_controller] #see if display controller has a handler
          target_controller = ctrlr if (not ctrlr.nil?) and ctrlr.methods.include?(action.to_sym)

          ctrlr = controllers[:screen_controller]  #else see if scereen controllerhas a handler
          target_controller ||= ctrlr if (not ctrlr.nil?) and ctrlr.methods.include?(action.to_sym)

          ctrlr = controllers[:app_controller]  #else see if app controller has a handler
          target_controller ||= ctrlr if (not ctrlr.nil?) and ctrlr.methods.include?(action.to_sym)

          ctrlr = RylyzAppController   #finally see if rylyz controller has a handler
          target_controller ||= ctrlr if (not ctrlr.nil?) and ctrlr.methods.include?(action.to_sym)

          target_controller.send(action, visitor, tokens) unless target_controller.nil?
          if target_controller.nil?
            msg = "#{action}: handler not found in the display, screen or the app controller! Design ERROR!"
            puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
            puts msg
            puts "tokens: #{tokens}"
            puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
            ev = { exception: msg }
            puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{wid}] server-side-exception"
            PusherChannels.instance.trigger_private_channel_event(wid, 'server-side-exception', ev)
            PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent server-side-exception [#{wid} (on wid)]"
          end
        rescue RuntimeError => e
          puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
          puts "WID Channel Runtime Exception invoking #{target_controller}.#{action}"
          puts "tokens: #{tokens}"
          puts "Exception: #{e}"
          puts e.backtrace
          puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
          #+++TODO make this a convenience function: to trigger exceptions back
          ev = { exception: e.to_s }
          puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{wid}] server-side-exception"
          PusherChannels.instance.trigger_private_channel_event(wid, 'server-side-exception', ev)
          PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent server-side-exception [#{wid} (on wid)]"
        rescue Exception => e
          puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
          puts "WID Channel Exception invoking #{target_controller}.#{action}"
          puts "tokens: #{tokens}"
          puts "Exception: #{e}"
          puts e.backtrace
          puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
          ev = { exception: e.to_s }
          puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{wid}] server-side-exception"
          PusherChannels.instance.trigger_private_channel_event(wid, 'server-side-exception', ev)
          PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent server-side-exception [#{wid} (on wid)]"
        else
          # Do this if no exception was raised
        ensure
          # Do this whether or not an exception was raised
        end
      end
    end
  end
end

# PusherChannels.instance.start_private_channel("app-service")
# PusherChannels.instance.on_private_channel_event("app-service", "start-app") do |data|
#   tokens = JSON.parse(params[:data])
#   app_name = tokens["app_name"]
#   # on_events - start channel_set
# end

# PusherChannels.instance.on_private_channel_event("wygyt", 'text-event') do |data|
#   puts "==== #{data} ===="
# end
