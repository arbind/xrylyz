source 'http://rubygems.org'

# technology stack
gem 'rails', '3.1.1'
gem 'mongoid' #MongoDB
gem 'bson_ext'
gem 'newrelic_rpm' #Server Monitoring
group :production do
  gem 'thin'
end

# performance profiler
gem 'ruby-prof'


# utils
gem 'json'
gem 'haml'
gem 'httparty'
gem 'addressable'
gem 'jquery-rails'
gem 'metainspector', '1.9.2'

# 3rd party services
gem 'stripe'
gem 'pusher'
gem 'pusher-client', :git => 'git://github.com/neocsr/pusher-client.git' # alpha client-side triggers
gem 'postageapp' #mass email service

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
