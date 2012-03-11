require 'singleton'
require 'httparty'
require 'pusher-client'

Pusher.app_id = '16344'
Pusher.key    = 'a9206fc7a3b77a7986c5'
Pusher.secret = '46bf19dc91f45ca2d1b0'

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

  def on_public_channel_event(channel_name, event_name, &blk)
    public_event_name = "rylyz-#{event_name}"
    on_channel_event(:public, channel_name, public_event_name, blk)
  end
  def on_private_channel_event(channel_name, event_name, &blk)
    private_event_name = "client-rylyz-#{event_name}"
    on_channel_event(:private, channel_name, private_event_name, blk)
  end
  def on_presence_channel_event(channel_name, event_name, &blk)
    presence_event_name = "client-rylyz-#{event_name}"
    on_channel_event(:presence, channel_name, presence_event_name, blk)
  end
  def on_channel_event(scope, channel, scoped_event_name, &blk)
    channel_socket(scope, channel_name).bind(scoped_event_name) do |data|
      begin #safeguard the handler block
        blk.call( data )
      rescue RuntimeError => e
        # Handle exception
      rescue Exception => e
        # Handle exception
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
    s = nil
    listener_thread = listener_thread_for_channel(scope,channel_name)
    s = listener_thread[:socket] if listener_thread
    s
  end

  def stop_public_channel(channel_name)   stop_channel(:public, channel_name)   end
  def stop_private_channel(channel_name)  stop_channel(:private, channel_name)  end
  def stop_presence_channel(channel_name) stop_channel(:presence, channel_name) end
  def stop_channel(scope, channel_name)
    channel = @channels[scope][channel_name]
    return if not channel
    #+++TODO turn off the socket and end the thread.

  end
  def start_public_channel(channel_name)   start_channel(:public, channel_name)   end
  def start_private_channel(channel_name)  start_channel(:private, channel_name)  end
  def start_presence_channel(channel_name) start_channel(:presence, channel_name) end
  def start_channel(scope, channel_name)
    @channels[scope][channel_name] ||= listener_thread_for_channel(scope, channel_name)
  end

  def listener_thread_for_channel(scope, channel_name)
    scoped_channel_name = "#{scope.to_s}-rylyz-#{channel_name}"
    listener_thread = Thread.new do
          puts "launching Thread #{scoped_channel_name}"
          Thread.current[:connected] = false
          Thread.current[scope] = true
          Thread.current[:name] = scoped_channel_name
          Thread.current[:start_time] = Time.now()
          Thread.current[:last_heartbeat] = nil

          options = {:secret => Pusher.secret}
          socket = PusherClient::Socket.new(Pusher.key, options)

          socket.subscribe(scoped_channel_name, "USER_ID")
          socket.bind('pusher:heartbeat') do |data|
            Thread.current[:last_heartbeat] = Time.now()
          end
          socket.bind('pusher:connection_established') do |data|
            Thread.current[:connected] = true
          end
          Thread.current[:socket] = socket

          socket.connect # thread goes to sleep and waits for channel events
        end
    sleep 0.1 while 'sleep'!=listener_thread.status #sleep main thread until listner_thread has started and is listening (in sleep mode)
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

p = PusherChannels.instance

p.on_private_channel_event("wyjyt", 'start-wyjyt') do |data|
   local_response = HTTParty.get('http://127.0.0.1:8000/pusher/test', :query => {:token => data})
end

p.on_private_channel_event("wyjyt", 'text-event') do |data|
  puts "==== #{data} ===="
end
