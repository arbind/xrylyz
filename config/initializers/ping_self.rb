PING_URI = URI.parse("http://#{RYLYZ_PLAYER_HOST}/ping")

ping_thread = Thread.new do
  loop do
    sleep 8*60 # 8 minutes
    Net::HTTP.get_response(PING_URI)
  end
end
ping_thread[:thread_name] = "ping self every 8m (rufus scheduler)"
