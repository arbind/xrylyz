RylyzPlayer::Application.configure do

RYLYZ_PLAYER_HOST = "rylyz-local.com"
RYLYZ_PLAYER_HOST.downcase!


  # Settings specified here will take precedence over those in config/application.rb

  #rylyz-local.com API Keys

  SECRETS = {
    :STRIPE => { #stripe Test Account
      :SECRET => '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG',
      :PUBLISH => 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'
    },
    :PUSHER => { # Christian's Beta account
      :APP_ID => '16344', # Christian's Beta account
      :KEY => 'a9206fc7a3b77a7986c5', # Christian's Beta account
      :SECRET => '46bf19dc91f45ca2d1b0', # Christian's Beta account
    },
    :TWITTER => {   # @rylyz: https://dev.twitter.com/apps/1897749/settings 
      :CONSUMER_KEY => 'y0jHav3TZX2XEKZoB8VgvA',
      :CONSUMER_SECRET => 'P32UGc2eWcMmcTg5w4TFjkH5pY34GJ2SbwBWlmbs'
    },
    :FACEBOOK => { # arbind.thakur: https://developers.facebook.com/apps/370553076322295/
      :APP_ID => '370553076322295',
      :APP_SECRET => '2c85411d97742ac7eaa5ccd2038945dc'
    },
    :GOOGLE_OAUTH2 => { # play@rylyz.com: https://code.google.com/apis/console/#project:340081981310
      :CLIENT_ID => '340081981310.apps.googleusercontent.com',
      :CLIENT_SECRET => 'KcYXzcgAhiodofS_nRctF6a5'
    },
    :TUMBLR => { # play@rylyz.com: http://www.tumblr.com/oauth/apps
      :CONSUMER_KEY => "IOLe2YbJoPY6oapdUQH502bcHkoQcLma2Z4C4WEI6p2D9Mxwi9",
      :SECRET => "4xv1dPr7zAqio3reYkvBGmTmYgK3R5MEf9wFWnHfEZseabY77D"
    },
    :RUNKEEPER => { # play@rylyz.com: http://runkeeper.com/partner/applications
      :CLIENT_ID => "aca3a807d9d74a51b25ef9ffdda2f217",
      :CLIENT_SECRET => "6ecd58ebae1d4b7abe0481e77d91b31b"
    },
    :WINDOWSLIVE => { # play@rylyz.com: https://manage.dev.live.com/Applications/Index: http://msdn.microsoft.com/en-us/library/hh243641.aspx
      :CLIENT_ID => "00000000400A7659",
      :SECRET => "es0zIJdOUFjiyKzaG6srV39uSjZXUSDB"
    },
    :YAHOO => { # google signin(play@rylyz.com): https://developer.apps.yahoo.com/projects !select 1 service(√Social Directory), then updated keys
      :CONSUMER_KEY => "dj0yJmk9MzhjSFdRVUl5bWw3JmQ9WVdrOWNIUlpNV2RQTXpRbWNHbzlNakEwTlRZMU5qRTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1hOQ--",
      :CONSUMER_SECRET => "a079790127b9ff3bb0bf8da597668af610263437"
    },    

  }
  # @rylyz: https://dev.twitter.com/apps/1897749/settings 
  # config.twitter_consumer_key = 'y0jHav3TZX2XEKZoB8VgvA'
  # config.twitter_consumer_secret = 'P32UGc2eWcMmcTg5w4TFjkH5pY34GJ2SbwBWlmbs'

  # arbind.thakur: https://developers.facebook.com/apps/370553076322295/
  # config.facebook_app_id = '370553076322295'
  # config.facebook_app_secret = '2c85411d97742ac7eaa5ccd2038945dc'

  # play@rylyz.com: https://code.google.com/apis/console/#project:340081981310
  # config.google_oauth2_client_id = '340081981310.apps.googleusercontent.com'
  # config.google_oauth2_client_secret = 'KcYXzcgAhiodofS_nRctF6a5'

  # config.linked_in_consumer_key = ''
  # config.linked_in_consumer_secret = ''

  #Pusher config
  # config.pusher_app_id = '16344'                # Christian's Beta account
  # config.pusher_key    = 'a9206fc7a3b77a7986c5' # Christian's Beta account
  # config.pusher_secret = '46bf19dc91f45ca2d1b0' # Christian's Beta account

  #stripe config test
  # config.stripe_secret  = '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG'
  # config.stripe_publish = 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'

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
