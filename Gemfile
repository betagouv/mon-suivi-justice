source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.2'
gem 'rails', '~> 7.2.2'

gem 'pg', '~> 1.6.3'
gem 'puma', '~> 6.6.1'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'turbo-rails', '~> 1.5.0'

gem 'devise', '~> 4.9.4'
gem 'devise-i18n', '~> 1.15.0'
gem 'devise_invitable', '~> 2.0.11'
gem 'devise-security', '>= 0.18.0'

gem 'pundit', '~> 2.5.2'
gem 'simple_form', '~> 5.4.1'
gem 'addressable', '~> 2.8.8' # fix scalingo deploy bug
gem 'cocoon', '~> 1.2.15'

gem 'phony_rails', '~> 0.15.0'

gem 'ransack', '~>4.4.1'
gem 'kaminari', '~> 1.2.2'

gem 'state_machines', '~> 0.100.4'
gem 'state_machines-activerecord', '~> 0.100.0'

gem 'sib-api-v3-sdk', '~> 9.1.0'
gem 'dotenv-rails', '~> 3.2.0'
gem 'sidekiq', '~> 7.3.9'
gem 'sidekiq-failures', '~> 1.1.0'
gem 'clockwork', '~> 3.0.2'

gem 'holidays', '~> 8.8.0'
gem 'discard', '~> 1.4.0'

gem 'paper_trail', '~> 17.0.0'
gem 'ahoy_matey', '~> 5.4.0'
gem 'sentry-ruby', '~> 5.28.0'
gem 'sentry-rails', '~> 5.28.1'
gem 'ruby-progressbar', '~> 1.13.0'

gem 'csv', '~> 3.3'
gem 'jbuilder', '~> 2.14.1'
gem 'groupdate', '~> 6.7.0'

gem 'faraday', '~> 2.14.0'
gem 'faraday-retry', '~> 2.4.0'
gem 'jwt', '~> 2.10'

gem 'wicked_pdf', '~> 2.8.2'
gem 'wkhtmltopdf-binary', '~> 0.12.6'

gem 'tzinfo', '~> 2.0.6'
gem 'tzinfo-data', '~> 1.2025.3'

gem 'administrate', '~> 0.19.0'
gem 'administrate-field-enum', '~> 0.0.9'

gem 'pretender', '~> 0.6.0'

gem 'octokit', '~> 9.2.0'

gem 'stimulus-rails', '~> 1.3.4'

gem 'lograge', '~> 0.14.0'

group :development, :test do
  gem 'rspec-rails', '~> 7.1.1'
  gem 'rspec_junit_formatter', '~> 0.6.0'
  gem 'factory_bot_rails', '~> 6.5.1'
  gem 'byebug', '~> 11.1.3', platforms: %i[mri mingw x64_mingw]
  gem 'pry-byebug', '~> 3.10.1'
  gem 'launchy', '~> 3.1.1'
  gem 'rails-controller-testing', '~> 1.0.5'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 3.3'
  gem 'listen', '~> 3.10.0'
  gem 'spring', '~> 4.4.2'
  gem 'rubocop', '~> 1.81', require: false
  gem 'brakeman', '~> 7.1'
  gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'guard-rubocop', '~> 1.5.0'
  gem 'letter_opener', '~> 1.10.0'
  gem 'rails-erd', '~> 1.7.2'
  gem 'htmlbeautifier', '~> 1.4', '>= 1.4.3'
  gem 'state_machines-graphviz', '~> 0.1.0'
  gem 'debug', '>= 1.0.0'
  gem 'bullet', '~> 8.1.0'
end

group :test do
  gem 'capybara', '>= 3.39.2'
  gem 'capybara-screenshot', '~> 1.0.26'
  gem 'selenium-webdriver', '~> 4.10.0'
  gem 'webdrivers', '~> 5.3.1'
  gem 'shoulda-matchers', '~> 6.5.0'
  gem 'timecop', '~> 0.9.10'
  gem 'pundit-matchers', '~> 4.0.0'
  gem 'state_machines-rspec', '~> 0.6.0'
  gem 'webmock', '~> 3.26.1'
end

gem 'abyme', '~> 0.7.0'

gem 'pg_search', '~> 2.3.7'
gem 'administrate-field-belongs_to_search', '~> 0.10.0'
gem 'faker', '~> 3.5.3'

# Use Redis for Action Cable
gem 'redis', '~> 5.4.1'

gem 'jsbundling-rails', '~> 1.3.1'

gem 'cssbundling-rails', '~> 1.4.3'

gem 'sprockets-rails', '~> 3.5.2', require: 'sprockets/railtie'
