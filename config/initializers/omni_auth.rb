
Rails.application.config.middleware.use OmniAuth::Builder do
  _cfg = RylyzPlayer::Application.config
	provider :twitter, _cfg.twitter_consumer_key, _cfg.twitter_consumer_secret
  provider :facebook, _cfg.facebook_app_id, RylyzPlayer::Application.config.facebook_app_secret
  # provider :linked_in, RylyzPlayer::Application.config.linked_in_consumer_key, RylyzPlayer::Application.config.linked_in_consumer_secret
  provider :google_oauth2, _cfg.google_oauth2_client_id, _cfg.google_oauth2_client_secret, {access_type: 'online', approval_prompt: ''}

end


