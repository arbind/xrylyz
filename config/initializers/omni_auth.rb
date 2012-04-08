require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :twitter, SECRETS[:TWITTER][:CONSUMER_KEY], SECRETS[:TWITTER][:CONSUMER_SECRET]
  provider :facebook, SECRETS[:FACEBOOK][:APP_ID], SECRETS[:FACEBOOK][:APP_SECRET]
  provider :google_oauth2, SECRETS[:GOOGLE_OAUTH2][:CLIENT_ID], SECRETS[:GOOGLE_OAUTH2][:CLIENT_SECRET], {access_type: 'online', approval_prompt: ''}
  provider :yahoo, SECRETS[:YAHOO][:CONSUMER_KEY], SECRETS[:YAHOO][:CONSUMER_SECRET]
  provider :windowslive, SECRETS[:WINDOWSLIVE][:CLIENT_ID], SECRETS[:WINDOWSLIVE][:SECRET], :scope => 'wl.basic'
  provider :tumblr, SECRETS[:TUMBLR][:CONSUMER_KEY], SECRETS[:TUMBLR][:SECRET]
  provider :runkeeper, SECRETS[:RUNKEEPER][:CLIENT_ID], SECRETS[:RUNKEEPER][:CLIENT_SECRET]
  provider :linkedin, SECRETS[:LINKEDIN][:API_KEY], SECRETS[:LINKEDIN][:SECRET_KEY]
  provider :meetup, SECRETS[:MEETUP][:KEY], SECRETS[:MEETUP][:SECRET]
  # netflix
  # soundcloud
  # rdio
end


