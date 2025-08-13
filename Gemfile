# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.1'

gem 'rails', '~> 7.1.5', '>= 7.1.5.1'

gem 'sprockets-rails'

gem 'pg', '~> 1.1'

gem 'puma', '>= 5.0'

gem 'importmap-rails'

gem 'turbo-rails'

gem 'stimulus-rails'

gem 'jbuilder'

gem 'tzinfo-data', platforms: %i[windows jruby]

gem 'bootsnap', require: false

# custom gems

gem 'devise'

gem 'activeadmin'

# gem 'sassc-rails'
gem 'dartsass-rails'

gem 'image_processing', '~> 1.12'

gem 'tailwindcss-rails'

gem 'paranoia', '~> 2.4'

gem 'kaminari'

gem 'dotenv-rails', groups: %i[development test]

gem 'omniauth'

gem 'omniauth-github'

gem 'rack-cors'

gem 'doorkeeper'

gem 'rabl'

gem 'flatpickr'

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug', platforms: %i[mri windows]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end
