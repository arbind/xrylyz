source 'http://rubygems.org'

gem 'rails', '3.1.1'
# gem 'rack', '1.3.6'
gem 'rack'

# run thin in production
group :production do
  gem 'thin'
	gem 'newrelic_rpm' #Server Monitoring
end

gem 'json'
gem 'haml'
gem 'jquery-rails'

gem 'addressable'
gem 'httparty'
gem 'metainspector'

gem 'stripe'
gem 'pusher'
gem 'pusher-client', :git => 'git://github.com/neocsr/pusher-client.git'

#mass email service
# gem 'postageapp'

#MongoDB
gem 'mongoid'
gem 'bson_ext'

#oauth
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
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


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

# To use ActiveModel: has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :development do
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem "guard-livereload"
  gem "yajl-ruby"
end

group :test do
  gem 'turn', :require => false # Pretty printed test output
end
