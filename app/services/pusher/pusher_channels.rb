class PusherChannels
  include Singleton

  # @@socket_logger = Logger.new('soceket_logger1')
  @@socket_logger = Logger.new(STDOUT)

  def self.socket_logger
    @@socket_logger
  end
  

  attr_reader :channels

  # def initialize
  #   @channels = {
  #     :public => {},
  #     :private => {},
  #     :presence => {}
  #   }
  #   db_populate_channels
  # end

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
      begin #safeguard the handler block
        # PusherChannels::socket_logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> Got #{scoped_event_name} on #{scope}-#{channel_name}"
        # PusherChannels::socket_logger.info "> #{data}"

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
        puts "o-------- Pusher Thread: Started"

        Thread.current[:name]           = "Pusher Listener"
        Thread.current[:start_time]     = Time.now()
        Thread.current[:pusher_socket]         = nil
        Thread.current[:pusher_connected]      = false
        Thread.current[:pusher_last_heartbeat] = nil

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

  def setup
    return :Already_Setup unless self.pusher_socket.nil?

    if not start_realtime_sockets
      puts "REALTIME SOCKETS ARE OFF"
    else
      puts "REAL_TIME = ON"
      self.connect do |socket|
        puts "Starting private channel wygyt"
        self.start_private_channel("wygyt")
        puts "Started private channel wygyt"
        self.on_private_channel_event("wygyt", "open-wid-channel") do |data|
          tokens = JSON.parse(data)

          wid = tokens["wid"]
          url = tokens["url"]
          socket_id = tokens["pusher_socket_id"]

          visitor = VISITOR_SOCKETS[socket_id]
          visitor.wid = wid  #+++ *** sometimes getting nil for visitor here - did not auth properly?
          visitor.source_url = url
          VISITOR_WIDS[wid] = visitor # make visitor available by wid lookup
          # puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sending[#wid}] update-me"
          self.trigger_private_channel_event(wid, "update-me", visitor.for_display)
          # PusherChannels::socket_logger.info "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Sent update-me [#{wid}] (on wid)]"
          puts "Starting private channel wid[#{wid}]"
          self.start_private_channel(wid)
          puts "Started private channel wid[#{wid}]"
          self.on_private_channel_event(wid, "event") do |data|
#==========================
            data_payload = Rack::Utils.escape(data)
            #  to post with cookies (sesson) see: http://dzone.com/snippets/custom-httphttps-getpost
            use_ssl = false
            host = RYLYZ_PLAYER_HOST
            path = "/capsule/wid_event/#{wid}?data=#{data_payload}"
            port = use_ssl ? 443: 80

            url = "http://#{host}#{path}"
            puts "----> #{url}"
            contents = HTTParty.get(url)
            puts "<---- #{contents}"

            # http = Net::HTTP.new(host, port)
            # http.use_ssl = use_ssl

            # resp, response_data = http.get(path, nil) # GET request -> so the host can set his cookies
            # cookie = resp.response['set-cookie'] # save cookie for wid

            # check response_data for errors

            # POST request -> logging in  - http://dzone.com/snippets/custom-httphttps-getpost
            # data = 'serwis=wp.pl&url=profil.html&tryLogin=1&countTest=1&logowaniessl=1&login_username=blah&login_password=blah'
            # headers = {
            # 'Cookie' => cookie,
            # 'Referer' => 'http://profil.wp.pl/login.html',
            # 'Content-Type' => 'application/x-www-form-urlencoded'
            # }
            # resp, data = http.post(path, data, headers)
            # # Output on the screen -> we should get either a 302 redirect (after a successful login) or an error page
            # puts 'Code = ' + resp.code
            # puts 'Message = ' + resp.message
            # resp.each {|key, val| puts key + ' = ' + val}
            # puts data

# =========================
          end

        end
      end
    end

    :Now_Setup
  end    


  def pusher_socket() PUSHER_SOCKET.first end
  def pusher_socket=(socket) PUSHER_SOCKET << socket if PUSHER_SOCKET.empty? end
  def pusher_listener_thread() PUSHER_LISTENER_THREAD.first end
  def pusher_listener_thread=(thread) PUSHER_LISTENER_THREAD << thread if PUSHER_LISTENER_THREAD.empty?  end


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
