require 'singleton'
require 'httparty'
require 'pusher-client'
require 'active_support/inflector'

Rails.application.config.after_initialize do
  Thread.new do
    sleep 2 # to allow the webserver to load
    capsule_setup_url = "http://#{RYLYZ_PLAYER_HOST}/capsule/setup"
    puts        "........................................."
    puts         capsule_setup_url
    puts        "........................................."
    contents   = HTTParty.get(capsule_setup_url)
    puts         contents
  end
end



PUSHER_SOCKET = [] # stores exactly one socket: since the constant itself can not be assigned, we put the socket into array
PUSHER_LISTENER_THREAD = [] # stores exactly one thread 
PUSHER_THREAD_POOL = []

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


# See: http://pusher.com/docs/pusher_protocol
# handlers = {
#  "pusher:heartbeat" => {},
#  "pusher:connection_established" => {},
#  "pusher:error" => {},  # "data": { "message": String, "code": Integer }
# }





# PusherChannels.instance.on_private_channel_event("wygyt", "start-wygyt") do |data|
#    local_response = HTTParty.get('http://127.0.0.1:8000/pusher/test', :query => {:data => data})
# end







# PusherChannels.instance.start_private_channel("app-service")
# PusherChannels.instance.on_private_channel_event("app-service", "start-app") do |data|
#   tokens = JSON.parse(params[:data])
#   app_name = tokens["app_name"]
#   # on_events - start channel_set
# end

# PusherChannels.instance.on_private_channel_event("wygyt", 'text-event') do |data|
#   puts "==== #{data} ===="
# end
