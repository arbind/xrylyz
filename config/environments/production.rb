RylyzPlayer::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

RYLYZ_PLAYER_HOST = ENV["RYLYZ_PLAYER_HOST"] unless ENV["RYLYZ_PLAYER_HOST"].nil?
RYLYZ_PLAYER_HOST ||= "#{ENV["HEROKU_APP_NAME"]}.herokuapp.com" unless ENV["HEROKU_APP_NAME"].nil?
RYLYZ_PLAYER_HOST ||= Socket::gethostname rescue "rylyz-local.com"
RYLYZ_PLAYER_HOST.downcase!

# Host specific configurations
if RYLYZ_PLAYER_HOST.include? "rylyz.ws"

  #stripe config LIVE PRODUCTION
  config.stripe_secret  = 'Ev7W4ozqnmHR5taP5uYpcpb0BQa5ShPG'
  config.stripe_publish = 'pk_QS5y9D5NgMZBHtEBVzfmeyN6xATEd'

  #Pusher config
  config.pusher_app_id = '16344'                # Christian's Beta account
  config.pusher_key    = 'a9206fc7a3b77a7986c5' # Christian's Beta account
  config.pusher_secret = '46bf19dc91f45ca2d1b0' # Christian's Beta account

  #social public key and secret
  # @rylyz: https://dev.twitter.com/apps/1903455
  config.twitter_consumer_key = 'ZyqnPpyUBueTUuqtzH1Ng'
  config.twitter_consumer_secret = 'CdguYoywcIwd3HVazs46Xf9q6fOF9wb3c3gpoWiLk'

  # arbind.thakur: https://developers.facebook.com/apps/146598735467471
  config.facebook_app_id = '146598735467471'
  config.facebook_app_secret = 'ce53141accc2db68dad6c08de77186ac'

  # play@rylyz.com: https://code.google.com/apis/console/#project:553342390312
  config.google_oauth2_client_id = '553342390312.apps.googleusercontent.com'
  config.google_oauth2_client_secret = 'IQrrG9SkDMJ-ROhmGeXYd2b0'

  config.linked_in_consumer_key = ''
  config.linked_in_consumer_secret = ''

elsif RYLYZ_PLAYER_HOST.include? "holodeck" # http://rylyz-holodeck.herokuapp.com/
  #stripe config TEST
  config.stripe_secret  = '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG'
  config.stripe_publish = 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'

  #Pusher config
  config.pusher_app_id = '16344'                # Christian's Beta account
  config.pusher_key    = 'a9206fc7a3b77a7986c5' # Christian's Beta account
  config.pusher_secret = '46bf19dc91f45ca2d1b0' # Christian's Beta account

  #social public key and secret

  # @rylyz: https://dev.twitter.com/apps/1903425
  config.twitter_consumer_key = 'cskTNpLHzPa5KDPegk907g'
  config.twitter_consumer_secret = 'r02Wp8t5fX3pBfH39oh3R8tdwdgugOsAekf4viTZLGg'

  # arbind.thakur: https://developers.facebook.com/apps/363689243672290
  config.facebook_app_id = '363689243672290'
  config.facebook_app_secret = 'cb4e812249cf3574b87c5be6049d2353'

  # play@rylyz.com: https://code.google.com/apis/console/#project:204876742071
  config.google_oauth2_client_id = '204876742071.apps.googleusercontent.com'
  config.google_oauth2_client_secret = 'pChiQ9umaWgH59l-_pV-E4-G'

  config.linked_in_consumer_key = ''
  config.linked_in_consumer_secret = ''

elsif RYLYZ_PLAYER_HOST.include? "demo" # http://rylyz-demo.herokuapp.com/
  #stripe config TEST
  config.stripe_secret  = '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG'
  config.stripe_publish = 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'

  #Pusher config
  config.pusher_app_id = '16344'                # Christian's Beta account
  config.pusher_key    = 'a9206fc7a3b77a7986c5' # Christian's Beta account
  config.pusher_secret = '46bf19dc91f45ca2d1b0' # Christian's Beta account

  #social public key and secret

  # @rylyz: https://dev.twitter.com/apps/1903425
  config.twitter_consumer_key = 'MaFYEJ9MvChVNqmvIi54A'
  config.twitter_consumer_secret = 'LSAf6bxngl85oxUJUnMh9e4HcpazntvmyWbKo5VPA'

  # arbind.thakur: https://developers.facebook.com/apps/404547726222115
  config.facebook_app_id = '404547726222115'
  config.facebook_app_secret = '263f5ff89d5229e37c0fae1e6c950373'

  # play@rylyz.com: https://code.google.com/apis/console/#project:1064365249820
  config.google_oauth2_client_id = '1064365249820.apps.googleusercontent.com'
  config.google_oauth2_client_secret = '1jzm3VKIdCY9HpAbJ2H7AmJl-ixP'

  config.linked_in_consumer_key = ''
  config.linked_in_consumer_secret = ''

elsif RYLYZ_PLAYER_HOST.include? "player" # http://rylyz-player.herokuapp.com/

  #stripe config TEST
  config.stripe_secret  = '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG'
  config.stripe_publish = 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'

  #Pusher config
  config.pusher_app_id = '16344'                # Christian's Beta account
  config.pusher_key    = 'a9206fc7a3b77a7986c5' # Christian's Beta account
  config.pusher_secret = '46bf19dc91f45ca2d1b0' # Christian's Beta account


  #social public key and secret

  # @rylyz: https://dev.twitter.com/apps/1903407
  config.twitter_consumer_key = 'zriy4eI2tWcJSBpHvv9qPw'
  config.twitter_consumer_secret = 'YJJqFOtMJB6V3TlvQTblE7KjdO6YyIgy34gBNKJ80'

  # arbind.thakur: https://developers.facebook.com/apps/328234480563622
  config.facebook_app_id = '328234480563622'
  config.facebook_app_secret = '52d9c4ceaa844c5dfe5adb9e047d9a0c'

  # play@rylyz.com: https://code.google.com/apis/console/#project:373759919659
  config.google_oauth2_client_id = '373759919659.apps.googleusercontent.com'
  config.google_oauth2_client_secret = 'wekXJJPeFZLSdcpumai4-ixP'

  config.linked_in_consumer_key = ''
  config.linked_in_consumer_secret = ''
end

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
