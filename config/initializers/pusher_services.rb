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

  def on_public_event(channel_name, event_name, &blk)
    public_event_name = "rylyz-#{event_name}"
    public_socket(channel_name).bind(public_event_name) do |data|
      blk.call( data )
    end
  end

  def on_private_event(channel_name, event_name, &blk)
    private_event_name = "client-rylyz-#{event_name}"
    private_socket(channel_name).bind(private_event_name) do |data|
      blk.call( data )
    end
  end
  def on_presence_event(channel_name, event_name, &blk)
    presence_event_name = "client-rylyz-#{event_name}"
    presence_socket(channel_name).bind(presence_event_name) do |data|
      blk.call( data )
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
          connection = PusherClient::Socket.new(Pusher.key, options)

          connection.subscribe(scoped_channel_name, "USER_ID")
          connection.bind('pusher:heartbeat') do |data|
            Thread.current[:last_heartbeat] = Time.now()
          end
          connection.bind('pusher:connection_established') do |data|
            Thread.current[:connected] = true
          end
          Thread.current[:socket] = connection

          connection.connect # thread goes to sleep and waits for channel events
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
#p.start_private_channel("wyjyt")
#p.start_private_channel("chat")

p.on_private_event("wyjyt", 'start-wyjyt') do |data|
   local_response = HTTParty.get('http://127.0.0.1:8000/pusher/test', :query => {:token => data})
end

p.on_private_event("wyjyt", 'text-event') do |data|
  puts "==== #{data} ===="
end
