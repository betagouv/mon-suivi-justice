source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'
gem 'rails', '~> 6.1.4', '>= 6.1.4.6'

gem 'pg', '~> 1.3'
gem 'puma', '~> 5.6'
gem 'sass-rails', '>= 6'
gem 'sassc', '2.3.0'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'bootsnap', '>= 1.4.4', require: false

gem 'devise', '~> 4.8'
gem 'devise-i18n', '~> 1.10'
gem 'devise_invitable', '~> 2.0.0'
gem 'devise-secure_password', '~> 2.0'

gem 'pundit', '~> 2.1'
gem 'simple_form', '~> 5.1'
gem 'addressable', '~> 2.8' # fix scalingo deploy bug
gem 'cocoon', '~> 1.2'

gem 'phony_rails', '~> 0.15'

gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'kaminari', '~> 1.2'
gem 'font-awesome-rails', '~> 4.7'

gem 'state_machines', '~> 0.5'
gem 'state_machines-activerecord', '~> 0.8'

gem 'sib-api-v3-sdk', '~> 8.0'
gem 'dotenv-rails', '~> 2.7'
gem 'sidekiq', '~> 6.4'
gem 'redis-namespace', '~> 1.8'
gem 'clockwork', '~> 3.0'

gem 'holidays', '~> 8.5'
gem 'discard', '~> 1.2'

gem 'paper_trail', '~> 12.2'
gem 'sentry-ruby', '~> 5.1'
gem 'sentry-rails', '~> 5.1'
gem 'ruby-progressbar', '~> 1.11'

gem 'jbuilder', '~> 2.11', '>= 2.11.5'

gem 'groupdate', '~> 6.0', '>= 6.0.1'

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'factory_bot_rails'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-byebug', '~> 3.9'
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
  gem 'letter_opener_web', '~> 2.0'
  gem 'rails-erd'
  gem 'state_machines-graphviz'
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
