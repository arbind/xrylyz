RylyzPlayer::Application.configure do

RYLYZ_PLAYER_HOST = "rylyz-local.com"
RYLYZ_PLAYER_HOST.downcase!


  # Settings specified here will take precedence over those in config/application.rb

  #rylyz-local.com API Keys

  # @rylyz: https://dev.twitter.com/apps/1897749/settings 
  config.twitter_consumer_key = 'y0jHav3TZX2XEKZoB8VgvA'
  config.twitter_consumer_secret = 'P32UGc2eWcMmcTg5w4TFjkH5pY34GJ2SbwBWlmbs'

  # arbind.thakur: https://developers.facebook.com/apps/370553076322295/
  config.facebook_app_id = '370553076322295'
  config.facebook_app_secret = '2c85411d97742ac7eaa5ccd2038945dc'

  # play@rylyz.com: https://code.google.com/apis/console/#project:340081981310
  config.google_oauth2_client_id = '340081981310.apps.googleusercontent.com'
  config.google_oauth2_client_secret = 'KcYXzcgAhiodofS_nRctF6a5'

  config.linked_in_consumer_key = ''
  config.linked_in_consumer_secret = ''

  #Pusher config
  config.pusher_app_id = '16344'                # Christian's Beta account
  config.pusher_key    = 'a9206fc7a3b77a7986c5' # Christian's Beta account
  config.pusher_secret = '46bf19dc91f45ca2d1b0' # Christian's Beta account

  #stripe config test
  config.stripe_secret  = '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG'
  config.stripe_publish = 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
end
