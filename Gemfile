source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

gem 'devise'
gem 'devise_invitable', '~> 2.0.0'
gem 'omniauth-oauth2', '~> 1.3.1'
gem 'omniauth-facebook', '~> 4.0'
gem 'rails', '~> 5.2.2'
gem 'pg'
gem 'puma', '~> 3.11'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'

# Generating the fake data(for testing)
gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'master'

# For send email(testing)
gem "letter_opener", :group => :development

# Responders
gem "responders"

# Active model serializer
gem 'active_model_serializers'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Geolocation
gem 'geocoder'

# For tagging
gem 'acts-as-taggable-on', '~> 5.0'

# Upload Image
gem 'carrierwave'
gem 'mini_magick'
gem 'carrierwave-base64'

# For implementing state machines
gem 'aasm'

# For jquery-ui-rails
gem 'jquery-rails'
gem 'jquery-ui-rails'

# For pagination
gem 'kaminari'

# Searching
gem 'ransack', github: 'activerecord-hackery/ransack'

# For user role authorities
gem "pundit"

gem 'kaminari'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'letter_opener'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
