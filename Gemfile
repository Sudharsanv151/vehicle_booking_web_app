source "https://rubygems.org"

ruby "3.4.1"

gem "rails", "~> 7.1.5", ">= 7.1.5.1"

gem "sprockets-rails"

gem "pg", "~> 1.1"

gem "puma", ">= 5.0"

gem "importmap-rails"

gem "turbo-rails"

gem "stimulus-rails"

gem "jbuilder"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "bootsnap", require: false

# custom gems

gem 'devise'

gem 'activeadmin'

gem 'sassc-rails'

gem "image_processing", "~> 1.12"

gem 'tailwindcss-rails'

gem 'paranoia', '~> 2.4'

gem 'kaminari'

gem 'dotenv-rails', groups: [:development, :test]

gem 'omniauth'

gem 'omniauth-github'

gem 'rack-cors'

gem 'doorkeeper'

gem 'rabl'




group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
end


group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem 'simplecov', require: false
end
