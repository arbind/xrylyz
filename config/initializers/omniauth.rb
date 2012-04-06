Rails.application.config.middleware.use OmniAuth::Builder do
	provider :twitter, RylyzPlayer::Application.config.twitter_consumer_key, RylyzPlayer::Application.config.twitter_consumer_secret
  provider :facebook, RylyzPlayer::Application.config.facebook_app_id, RylyzPlayer::Application.config.facebook_app_secret
  # provider :linked_in, RylyzPlayer::Application.config.linked_in_consumer_key, RylyzPlayer::Application.config.linked_in_consumer_secret
  # provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {access_type: 'online', approval_prompt: ''}
end


