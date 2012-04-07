require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :twitter, SECRETS[:TWITTER][:CONSUMER_KEY], SECRETS[:TWITTER][:CONSUMER_SECRET]
  provider :facebook, SECRETS[:FACEBOOK][:APP_ID], SECRETS[:FACEBOOK][:APP_SECRET]
  provider :google_oauth2, SECRETS[:GOOGLE_OAUTH2][:CLIENT_ID], SECRETS[:GOOGLE_OAUTH2][:CLIENT_SECRET], {access_type: 'online', approval_prompt: ''}
  provider :yahoo, SECRETS[:YAHOO][:CONSUMER_KEY], SECRETS[:YAHOO][:CONSUMER_SECRET]
  provider :tumblr, SECRETS[:TUMBLR][:CONSUMER_KEY], SECRETS[:TUMBLR][:SECRET]
  provider :runkeeper, SECRETS[:RUNKEEPER][:CLIENT_ID], SECRETS[:RUNKEEPER][:CLIENT_SECRET]
  provider :windowslive, SECRETS[:WINDOWSLIVE][:CLIENT_ID], SECRETS[:WINDOWSLIVE][:SECRET], :scope => 'wl.basic'
  # provider :linked_in, OAUTH_API[:LINKEDIN][:CONSUMER_KEY], OAUTH_API[:LINKEDIN][:CONSUMER_SECRET]

  # these are are not setup properly
  # provider :openid, :store => OpenID::Store::Filesystem.new('/tmp'), :name => "google_openid", :identifier => "https://www.google.com/accounts/o8/id"
	# provider :openid, :store => OpenID::Store::Filesystem.new('/tmp'), :name => "yahoo_openid", :identifier => "https://me.yahoo.com"

  # provider :openid, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'openid'
end


