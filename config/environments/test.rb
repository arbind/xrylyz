RylyzPlayer::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

RYLYZ_PLAYER_HOST = ENV["RYLYZ_PLAYER_HOST"] unless ENV["RYLYZ_PLAYER_HOST"].nil?
RYLYZ_PLAYER_HOST ||= "#{ENV["HEROKU_APP_NAME"]}.herokuapp.com" unless ENV["HEROKU_APP_NAME"].nil?
RYLYZ_PLAYER_HOST ||= Socket::gethostname rescue "holodeck.rylyz.ws"
RYLYZ_PLAYER_HOST.downcase!


# holodeck is kind of like our test environment
if RYLYZ_PLAYER_HOST.include? "holodeck" #http://rylyz-holodeck.herokuapp.com/
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
    }
  }
end

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end
