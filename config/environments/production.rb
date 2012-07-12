RylyzPlayer::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

RYLYZ_PLAYER_HOST = ENV['RYLYZ_PLAYER_HOST'] unless ENV['RYLYZ_PLAYER_HOST'].empty?
RYLYZ_PLAYER_HOST ||= "#{ENV['HEROKU_APP_NAME']}.herokuapp.com" unless ENV['HEROKU_APP_NAME'].empty?
RYLYZ_PLAYER_HOST ||= Socket::gethostname rescue "rylyz-local.com"

puts "ENV['HEROKU_APP_NAME'] set to #{ENV['HEROKU_APP_NAME']}"
puts "RYLYZ_PLAYER_HOST set to #{RYLYZ_PLAYER_HOST}"

# Host specific configurations
if RYLYZ_PLAYER_HOST.include? "rylyz.ws"
  # See everything in the log (default is :info)
  config.log_level = :debug
  
  puts "DEFINING SECRETS FOR rylyz.ws (LIVE)"

  SECRETS = {
    :STRIPE => { # LIVE CONFIG - MAKES REAL CREDIT CARD CHARGES
      :SECRET => 'Ev7W4ozqnmHR5taP5uYpcpb0BQa5ShPG',
      :PUBLISH => 'pk_QS5y9D5NgMZBHtEBVzfmeyN6xATEd'
    },
    :PUSHER => { # Christian's Beta account
      :APP_ID => '16344', # Christian's Beta account
      :KEY => 'a9206fc7a3b77a7986c5', # Christian's Beta account
      :SECRET => '46bf19dc91f45ca2d1b0', # Christian's Beta account
    },
    :TWITTER => { # @rylyz: https://dev.twitter.com/apps/1903455
      :CONSUMER_KEY => 'ZyqnPpyUBueTUuqtzH1Ng',
      :CONSUMER_SECRET => 'CdguYoywcIwd3HVazs46Xf9q6fOF9wb3c3gpoWiLk'
    },
    :FACEBOOK => { # arbind.thakur: https://developers.facebook.com/apps/146598735467471 
      :APP_ID => '146598735467471',
      :APP_SECRET => 'ce53141accc2db68dad6c08de77186ac'
    },
    :GOOGLE_OAUTH2 => { # play@rylyz.com: https://code.google.com/apis/console/#project:553342390312
      :CLIENT_ID => '553342390312.apps.googleusercontent.com',
      :CLIENT_SECRET => 'IQrrG9SkDMJ-ROhmGeXYd2b0'
    },
    :TUMBLR => { # play@rylyz.com: http://www.tumblr.com/oauth/apps
      :CONSUMER_KEY => "bcCJUK169arqDEzvteyM7AvMjXN4H7gSCg4lpA0umcyfIlNFZl",
      :SECRET => "Nu98zdpQdGkQs7MGsmtuZROvkIwKY48m1CQa4AwR5VVn9tjDFD"
    },
    :RUNKEEPER => { # play@rylyz.com: http://runkeeper.com/partner/applications
      :CLIENT_ID => "14513bcfd678454098a165495e076299",
      :CLIENT_SECRET => "af61d47fcc8d440da01f120c2889de95"
    },
    :WINDOWSLIVE => { # play@rylyz.com: https://manage.dev.live.com/Applications/Index: http://msdn.microsoft.com/en-us/library/hh243641.aspx
      :CLIENT_ID => "00000000400A7976",
      :SECRET => "PW6mhzSi-W8ST3NfGV9RgJg1rPiFp-g6"
    },
    :YAHOO => { # google signin(play@rylyz.com): https://developer.apps.yahoo.com/projects !select 1 service(√Social Directory), then updated keys
      :CONSUMER_KEY => "dj0yJmk9ZTBGdGVPUHljb2dKJmQ9WVdrOVNXRmxORTFOTm1zbWNHbzlNVEUxTmpBME1qYzJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1lMA--",
      :CONSUMER_SECRET => "0161f8ad2a8ae45387bc7d6c039a1367354784f1"
    },
    :LINKEDIN => { # play@rylyz.com: https://www.linkedin.com/secure/developer
      :API_KEY => "mptdgs5bqv5h",
      :SECRET_KEY => "Dm5aJ8T2XScNmFIa"
    },
    :MEETUP => {}, #+++ add meetup

  }

elsif RYLYZ_PLAYER_HOST.include? "holodeck" # http://rylyz-holodeck.herokuapp.com/
  # See everything in the log (default is :info)
  config.log_level = :debug
  
  puts "DEFINING SECRETS FOR HOLODECK"

  SECRETS = {
    :STRIPE => { # TEST CONFIG
      :SECRET => '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG',
      :PUBLISH => 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'
    },
    :PUSHER => { # Christian's Beta account
      :APP_ID => '16344', # Christian's Beta account
      :KEY => 'a9206fc7a3b77a7986c5', # Christian's Beta account
      :SECRET => '46bf19dc91f45ca2d1b0', # Christian's Beta account
    },
    :TWITTER => { # @rylyz: https://dev.twitter.com/apps/1903425
      :CONSUMER_KEY => 'cskTNpLHzPa5KDPegk907g',
      :CONSUMER_SECRET => 'r02Wp8t5fX3pBfH39oh3R8tdwdgugOsAekf4viTZLGg'
    },
    :FACEBOOK => { # arbind.thakur: https://developers.facebook.com/apps/363689243672290
      :APP_ID => '363689243672290',
      :APP_SECRET => 'cb4e812249cf3574b87c5be6049d2353'
    },
    :GOOGLE_OAUTH2 => { # play@rylyz.com: https://code.google.com/apis/console/#project:204876742071
      :CLIENT_ID => '204876742071.apps.googleusercontent.com',
      :CLIENT_SECRET => 'pChiQ9umaWgH59l-_pV-E4-G'
    },
    :TUMBLR => { # play@rylyz.com: http://www.tumblr.com/oauth/apps
      :CONSUMER_KEY => "IhdxmKfTFyGTgyhvM9WBdB0HQ50F5NQmMNH4rVwDoUEEarDLz2",
      :SECRET => "onl5R0etXY0rPY6PhpR3UfpwvcJMu4SybIn0qFKUkWzlBtoYlv"
    },
    :RUNKEEPER => { # play@rylyz.com: http://runkeeper.com/partner/applications
      :CLIENT_ID => "56bd013451804c1fab8429ba8389c6bf",
      :CLIENT_SECRET => "967a6922613f48668f06cb2b46d298ab"
    },
    :WINDOWSLIVE => { # play@rylyz.com: https://manage.dev.live.com/Applications/Index: http://msdn.microsoft.com/en-us/library/hh243641.aspx
      :CLIENT_ID => "00000000480A479F",
      :SECRET => "KvP0k0VcpodnMw-l7eXD5F2ZH0jZKtab"
    },
    :YAHOO => { # google signin(play@rylyz.com): https://developer.apps.yahoo.com/projects !select 1 service(√Social Directory), then updated keys
      :CONSUMER_KEY => "dj0yJmk9ajhHOUU1YnN2SEc2JmQ9WVdrOVNrTldjREo0TkRRbWNHbzlPRFF3TURNeU5EWXkmcz1jb25zdW1lcnNlY3JldCZ4PWIx",
      :CONSUMER_SECRET => "37cac6cf8ec22cc1c9c6189e495413144191cb4b"
    },
    :LINKEDIN => { # play@rylyz.com: https://www.linkedin.com/secure/developer
      :API_KEY => "5yu4urvu0p0l",
      :SECRET_KEY => "bIfkgiOsZfS05Fmg"
    },
    :MEETUP => {}, #+++ add meetup

  }

elsif RYLYZ_PLAYER_HOST.include? "demo" # http://rylyz-demo.herokuapp.com/
  # See everything in the log (default is :info)
  config.log_level = :debug
  
  puts "DEFINING SECRETS FOR DEMO"

  SECRETS = {
    :STRIPE => { #TEST CONFIG
      :SECRET => '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG',
      :PUBLISH => 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'
    },
    :PUSHER => { # Christian's Beta account
      :APP_ID => '16344', # Christian's Beta account
      :KEY => 'a9206fc7a3b77a7986c5', # Christian's Beta account
      :SECRET => '46bf19dc91f45ca2d1b0', # Christian's Beta account
    },
    :TWITTER => { # @rylyz: https://dev.twitter.com/apps/1903425
      :CONSUMER_KEY => 'MaFYEJ9MvChVNqmvIi54A',
      :CONSUMER_SECRET => 'LSAf6bxngl85oxUJUnMh9e4HcpazntvmyWbKo5VPA'
    },
    :FACEBOOK => { # arbind.thakur: https://developers.facebook.com/apps/404547726222115
      :APP_ID => '404547726222115',
      :APP_SECRET => '263f5ff89d5229e37c0fae1e6c950373'
    },
    :GOOGLE_OAUTH2 => { # play@rylyz.com: https://code.google.com/apis/console/#project:1064365249820
      :CLIENT_ID => '1064365249820.apps.googleusercontent.com',
      :CLIENT_SECRET => '1jzm3VKIdCY9HpAbJ2H7AmJl-ixP'
    },
    :TUMBLR => { # play@rylyz.com: http://www.tumblr.com/oauth/apps
      :CONSUMER_KEY => "Gl2PYBU5WJ4zi218zf7cVyKKgWEaPHZTzaVUai5dR31NmI7vK7",
      :SECRET => "Cq0I5AnRYhsfTuXAhq7ekRsz0wrZRfBixVYxdwZhrBxFs0CPnf"
    },
    :RUNKEEPER => { # play@rylyz.com: http://runkeeper.com/partner/applications
      :CLIENT_ID => "07d8f29888a740f1960f1bb938ee1f4a",
      :CLIENT_SECRET => "15769a85840640e5854cdfd84ae1a62e"
    },
    :WINDOWSLIVE => { # play@rylyz.com: https://manage.dev.live.com/Applications/Index: http://msdn.microsoft.com/en-us/library/hh243641.aspx
      :CLIENT_ID => "00000000400A7975",
      :SECRET => "cAcoYNKu7sfORSXck9meEhBTiqqMD44j"
    },
    :YAHOO => { # google signin(play@rylyz.com): https://developer.apps.yahoo.com/projects !select 1 service(√Social Directory), then updated keys
      :CONSUMER_KEY => "dj0yJmk9YnE3eTZob0hOM1k1JmQ9WVdrOWJUUlhNRzVSTXpRbWNHbzlNVGcxTXpFM09UUTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1iOA--",
      :CONSUMER_SECRET => "e21be564a9bd79139d3d76a8141f4ab01b618327"
    },    
    :LINKEDIN => { # play@rylyz.com: https://www.linkedin.com/secure/developer
      :API_KEY => "ra9iwn3dwrt7",
      :SECRET_KEY => "0XAILiDaxucguoDE"
    },
    :MEETUP => {}, #+++ add meetup

  }
  
elsif RYLYZ_PLAYER_HOST.include? "player" # http://rylyz-player.herokuapp.com/
  # See everything in the log (default is :info)
  config.log_level = :debug
  
  puts "DEFINING SECRETS FOR PLAYER"

  SECRETS = {
    :STRIPE => { # TEST CONFIG
      :SECRET => '5LeZ5IabCsvLNA8YHZOwaILWpGPaFFlG',
      :PUBLISH => 'pk_fA9y8hjM5PLXy9Ubdh7VcZyvNH0dH'
    },
    :PUSHER => { # Christian's Beta account
      :APP_ID => '16344', # Christian's Beta account
      :KEY => 'a9206fc7a3b77a7986c5', # Christian's Beta account
      :SECRET => '46bf19dc91f45ca2d1b0', # Christian's Beta account
    },
    :TWITTER => { # @rylyz: https://dev.twitter.com/apps/1903407
      :CONSUMER_KEY => 'zriy4eI2tWcJSBpHvv9qPw',
      :CONSUMER_SECRET => 'YJJqFOtMJB6V3TlvQTblE7KjdO6YyIgy34gBNKJ80'
    },
    :FACEBOOK => { # arbind.thakur: https://developers.facebook.com/apps/328234480563622
      :APP_ID => '328234480563622',
      :APP_SECRET => '52d9c4ceaa844c5dfe5adb9e047d9a0c'
    },
    :GOOGLE_OAUTH2 => { # play@rylyz.com: https://code.google.com/apis/console/#project:373759919659
      :CLIENT_ID => '373759919659.apps.googleusercontent.com',
      :CLIENT_SECRET => 'wekXJJPeFZLSdcpumai4-ixP'
    },
    :TUMBLR => { # play@rylyz.com: http://www.tumblr.com/oauth/apps
      :CONSUMER_KEY => "NKD6KWoP6LAjtMACVPy6SAoUsKwPzE4moN71dQH5S8Y93MjP3t",
      :SECRET => "MItmz5vfnccbimSNInABEkabTLw2t5ClVHuye5CgPuEQSkXSlF"
    },
    :RUNKEEPER => { # play@rylyz.com: http://runkeeper.com/partner/applications
      :CLIENT_ID => "bb93f338539b471195c06f2085daae56",
      :CLIENT_SECRET => "c89dfece7ae149469876f6146ab654f1"
    },
    :WINDOWSLIVE => { # play@rylyz.com: https://manage.dev.live.com/Applications/Index: http://msdn.microsoft.com/en-us/library/hh243641.aspx
      :CLIENT_ID => "00000000400A7974",
      :SECRET => "E-fJxbmAUbH0iT02nxE160KLvlmIX3z3"
    },
    :YAHOO => { # google signin(play@rylyz.com): https://developer.apps.yahoo.com/projects !select 1 service(√Social Directory), then updated keys
      :CONSUMER_KEY => "dj0yJmk9T05FdUd0Y3A3cjNMJmQ9WVdrOU1teHRZWGh1TjJFbWNHbzlOamN6Tmpjd05UWXkmcz1jb25zdW1lcnNlY3JldCZ4PTVh",
      :CONSUMER_SECRET => "a47047cab30858cb859851f03fa1ea06c98771ec"
    },
    :LINKEDIN => { # play@rylyz.com: https://www.linkedin.com/secure/developer
      :API_KEY => "yfjif2yr1rju",
      :SECRET_KEY => "fc96JcgAENamiSxP"
    },    
    :MEETUP => {}, #+++ add meetup

  }

else # default empty since heroku rake tasks do not always load environment variables: RYLYZ_PLAYER_HOST will be nil
  # See everything in the log (default is :info)
  config.log_level = :debug
  SECRETS = {
    :STRIPE => {},
    :PUSHER => {},
    :TWITTER => {},
    :FACEBOOK => {},
    :GOOGLE_OAUTH2 => {},
    :TUMBLR => {},
    :RUNKEEPER => {},
    :WINDOWSLIVE => {},
    :YAHOO => {},
    :LINKEDIN => {},
    :MEETUP => {},
  }

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
  #config.assets.digest = true <- breaks scss compilation when using @import
  config.assets.digest = false

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

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
