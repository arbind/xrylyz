PostageApp.configure do |config|
  config.api_key = 'q0cygShe1yn3h538JDYUNzNZlqbS18Zr'
  config.recipient_override = 'you@example.com' unless RYLYZ_PLAYER_HOST.include? "rylyz.com"
end
