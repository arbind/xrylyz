class PusherChannels
  include Singleton

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
    # puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{scoped_channel_name}] #{event_name}"
    Pusher[scoped_channel_name].trigger(event_name, tokens.to_json )
    # PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent #{event_name} [#{scope}-#{channel_name}]"
    # PusherChannels::socket_logger.info "<--------------------------- #{tokens.to_json}]"
  end

  def on_public_channel_event(channel_name, event_name, &block)
    public_event_name = "rylyz-#{event_name}"
    self.bind_channel_event_handler(:public, channel_name, public_event_name, block)
  end
  def on_private_channel_event(channel_name, event_name, &block)
    private_event_name = "client-rylyz-#{event_name}"
    self.bind_channel_event_handler(:private, channel_name, private_event_name, block)
  end
  def on_presence_channel_event(channel_name, event_name, &block)
    presence_event_name = "client-rylyz-#{event_name}"
    self.bind_channel_event_handler(:presence, channel_name, presence_event_name, block)
  end
  def bind_channel_event_handler(scope, channel_name, scoped_event_name, handler)
    raise "Not connected to Pusher!" if self.pusher_socket.nil?
    scoped_channel_name = materialize_channel_name(scope, channel_name)

    channel = self.pusher_socket.channels[scoped_channel_name]
    raise "Not subscribed to #{scope}: #{scoped_channel_name}! Can not bind event handler or #{scoped_event_name}" if channel.nil?

    channel.bind(scoped_event_name) do |data|
      # When a channel event comes in, schedule it to be run by a thread pool so this thread can continue listening
      pusher_thread_pool.schedule(scoped_event_name, data) do |scoped_event_name, data|
        begin #safeguard the handler block
          Speed.of("handling #{scoped_event_name} on channel #{scope}-#{channel_name}") do
          handler.call( data )
          end

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
    # puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#{scoped_channel_name}] stopped-listening"
    Pusher[scoped_channel_name].trigger("stopped-listening", {}.to_json )
    # PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent stopped-listening [#{scope}-#{channel_name}]"

    if @listener_thr
      socket = @listener_thr[:socket]
      socket.unsubscribe(scoped_channel_name)
    end
  end

  def start_public_channel(channel_name, handlers=nil)   start_channel(:public, channel_name, handlers)   end
  def start_private_channel(channel_name, handlers=nil)  start_channel(:private, channel_name, handlers)  end
  def start_presence_channel(channel_name, handlers=nil) start_channel(:presence, channel_name, handlers) end
  def start_channel(scope, channel_name, handlers=nil)
    # puts "o--- start_channel with scope: #{scope} for channel_name: #{channel_name}"
    channel = subscribe_to_channel(scope, channel_name)
    return if handlers.nil?

    # puts "o--- binding #{handlers.count} handlers to channel #{scope}:#{channel_name} for event:#{event_name}"
    handlers.each do |event_name, handler_blk|
      bind_channel_event_handler(scope, channel_name, event_name, handler_blk)
    end
    nil
  end

  def subscribe_to_channel(scope, channel_name, user_id=RYLYZ_PLAYER_HOST)
    scoped_channel_name = materialize_channel_name(scope, channel_name)
    channel = self.pusher_socket.subscribe(scoped_channel_name, user_id)
    if (channel.subscribed)
      self.trigger_channel_event(scope, channel_name, "started-listening", {}.to_json)
      # puts  "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent started-listening [#{scope}-#{channel_name}]"
      # PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent started-listening [#{scope}-#{channel_name}]"
    end
    channel
  end

  def connect(&on_connection_established)
    return unless self.pusher_listener_thread.nil?

    begin # create a new socket and subscribe to channel  
      self.pusher_listener_thread = Thread.new do
        puts "\no-------- Pusher Thread: Started"

        Thread.current[:name]           = "Pusher Listener"
        Thread.current[:start_time]     = Time.now()
        Thread.current[:pusher_socket]         = nil
        Thread.current[:pusher_connected]      = false
        Thread.current[:pusher_last_heartbeat] = nil
        Thread.current[:num_jobs] = 0

        self.pusher_socket = open_socket(on_connection_established)

        self.pusher_socket.connect unless self.pusher_socket.nil? # thread goes to sleep and waits for channel events
        puts "!-------- Pusher Thread: NO LONGER LISTENING TO PUSHER CHANNEL EVENTS"
      end
      self.pusher_listener_thread.priority = 1
      puts "o-------- Pusher Thread: Listener Launched and Runing"
    rescue Exception => e
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
      puts "!!! Could not launch Pusher listener thread."
      puts "----- Exception! #{e}"
      puts e.backtrace
      puts ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    end
    self.pusher_listener_thread
  end

  def open_socket(on_connection_established)
    begin
      puts "o-------- Pusher Socket: opening connection"
      socket = PusherClient::Socket.new(Pusher.key, {:secret => Pusher.secret} )

      socket.bind('pusher:connection_established') do |data|
        puts "o-------- Pusher Socket: connected"
        Thread.current[:pusher_connected]      = true
        Thread.current[:pusher_socket]         = socket
        Thread.current[:messgae]      = "Opened Pusher Socket"
        on_connection_established.call(socket)
      end

      socket.bind('pusher:connection_failed') do |data|
        Thread.current[:messgae]      = "Failed to open Pusher Socket"
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

  def start_realtime_sockets
    return true if ("on" == ENV['REAL_TIME'].to_s.downcase)
    return false if ("off" == ENV['REAL_TIME'].to_s.downcase)
    return false if ("assets" == ENV['RAILS_GROUPS'].to_s.downcase)
    return false if defined?(Rails::Console)
    return true
  end

  puts "CONSOLE IS RUNNING" if defined?(Rails::Console)
  puts "RAILS_GROUPS = #{ENV['RAILS_GROUPS']}" if ENV['RAILS_GROUPS']

  def setup
    return :Already_Setup if self.pusher_socket

    unless start_realtime_sockets
      puts "REALTIME SOCKETS ARE OFF"
      return :REAL_TIME_is_OFF
    end

    puts "=========================================="
    puts "REAL_TIME = ON"
    puts "Pusher using #{ENV['RAILS_ENV']} mode settings"
    puts "Pusher app_id => #{SECRETS[:PUSHER][:APP_ID]}"
    puts "Pusher key    => #{SECRETS[:PUSHER][:KEY]}"
    puts "=========================================="

    self.pusher_thread_pool = ThreadPool.new()

    use_ssl = false
    host = RYLYZ_PLAYER_HOST
    port = use_ssl ? 443: 80
    on_wygyt_event_path = "/capsule/on_wygyt_event"
    on_wygyt_opened_path = "/capsule/on_wygyt_opened"

    # connect to pusher, on success:
    #   setup a shared wygyt channel and its one event handler (that opens new wid channels unique to each client)
    self.connect do |socket|
      # Once we connect to pusher, start a channel to listen for new wygyt connections (shared by all clients)
      ::PusherChannels.instance.start_private_channel("wygyt")
      ::PusherChannels.instance.on_private_channel_event("wygyt", "open-wid-channel") do |data|
        # New wygyt has connected and is requesting to open a wid channel (unique to each client) 
        # First, start listening for events on the requested wid (wygyt id) channel
        # Then send the new wygyt connection info to capsule controller to start a session for this wygyt
        #   (once asession is started, the client can close its shared wygyt channel and start communicating on its private wid channel)
        # the wid channel name is generate by the client and provided when requesting to open-wid-channel

        # subscribe to this wygyt's wid channel 
        tokens = JSON.parse(data)
        wid = tokens["wid"]
        ::PusherChannels.instance.start_private_channel(wid)
        ::PusherChannels.instance.on_private_channel_event(wid, "event") do |data|
          # send wygyt events to the capsule controller
          path =  "#{on_wygyt_event_path}/#{wid}"
          Util.http_get(host, path, {data: data})
        end

        # start a session for this new wygyt
        path =  "#{on_wygyt_opened_path}/#{wid}"
        Util.http_get(host, path, {data: data})
      end
    end
    :Now_Setup
  end    

  def pusher_socket() PUSHER_SOCKET.first end
  def pusher_socket=(socket) PUSHER_SOCKET << socket if PUSHER_SOCKET.empty? end
  def pusher_listener_thread() PUSHER_LISTENER_THREAD.first end
  def pusher_listener_thread=(thread) PUSHER_LISTENER_THREAD << thread if PUSHER_LISTENER_THREAD.empty?  end

  def pusher_thread_pool() PUSHER_THREAD_POOL.first end
  def pusher_thread_pool=(pool) PUSHER_THREAD_POOL << pool if PUSHER_THREAD_POOL.empty? end

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
