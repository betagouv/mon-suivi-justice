source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'
gem 'rails', '~> 6.1.3', '>= 6.1.3.2'

gem 'pg'
gem 'puma', '~> 5.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'bootsnap', '>= 1.4.4', require: false

gem 'devise'
gem 'devise-i18n'
gem 'devise_invitable', '~> 2.0.0'

gem 'pundit'
gem 'simple_form'
gem 'addressable' # fix scalingo deploy bug
gem 'cocoon'

gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'kaminari'
gem 'font-awesome-rails'

gem 'state_machines'
gem 'state_machines-activerecord'

gem 'sib-api-v3-sdk'
gem 'dotenv-rails'
gem 'sidekiq'
gem 'redis-namespace'

gem 'holidays'

gem 'paper_trail'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'launchy', '~> 2.4', '>= 2.4.3'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  gem 'letter_opener'
  gem 'rails-erd'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'state_machines-rspec'
  gem 'webmock'
end
