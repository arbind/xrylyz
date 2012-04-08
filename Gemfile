source 'http://rubygems.org'

gem 'rails', '3.1.1'

# run thin in production
group :production do
  gem 'thin'
	gem 'newrelic_rpm' #Server Monitoring
end


#MongoDB
gem 'mongoid'
gem 'bson_ext'

#oauth
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-openid'
gem 'omniauth-tumblr'
gem 'omniauth-runkeeper'
gem 'omniauth-yahoo'
gem 'omniauth-windowslive'
gem 'omniauth-linkedin'
gem 'omniauth-meetup'
# gem 'omniauth-soundcloud'
# gem 'omniauth-netflix'
# gem 'omniauth-github'
# gem 'omniauth-foursquare'
# gem 'omniauth-flickr'
# gem 'omniauth-eventbrite'



gem 'json'
gem 'haml'
gem 'jquery-rails'

gem 'addressable'
gem 'httparty'

gem 'pusher'
gem 'pusher-client', :git => 'git://github.com/neocsr/pusher-client.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

#gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
#gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end
