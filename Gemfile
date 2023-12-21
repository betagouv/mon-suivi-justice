source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'
gem 'rails', '~> 7.0.0', '>= 7.0.8'

gem 'pg', '~> 1.3'
gem 'puma', '~> 6.4'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'turbo-rails', '~> 1.5'

gem 'devise', '~> 4.9'
gem 'devise-i18n', '~> 1.12'
gem 'devise_invitable', '~> 2.0.9'
gem 'devise-security', '>= 0.18.0'

gem 'pundit', '~> 2.1'
gem 'simple_form', '~> 5.1'
gem 'addressable', '~> 2.8' # fix scalingo deploy bug
gem 'cocoon', '~> 1.2'

gem 'phony_rails', '~> 0.15'

gem 'ransack', '~>4.1'
gem 'kaminari', '~> 1.2'

gem 'state_machines', '~> 0.5'
gem 'state_machines-activerecord', '~> 0.8'

gem 'sib-api-v3-sdk', '~> 9.0'
gem 'dotenv-rails', '~> 2.7'
gem 'sidekiq', '~> 7.1'
gem 'sidekiq-failures', '~> 1.0'
gem 'clockwork', '~> 3.0'

gem 'holidays', '~> 8.5'
gem 'discard', '~> 1.2'

gem 'paper_trail', '~> 12.2'
gem 'ahoy_matey', '~> 4.1'
gem 'sentry-ruby', '~> 5.15'
gem 'sentry-rails', '~> 5.15'
gem 'ruby-progressbar', '~> 1.11'

gem 'jbuilder', '~> 2.11', '>= 2.11.5'
gem 'groupdate', '~> 6.4'

gem 'faraday', '~> 2.7'
gem 'faraday-retry', '~> 2.2'

gem 'wicked_pdf', '~> 2.6'
gem 'wkhtmltopdf-binary', '~> 0.12'

gem 'tzinfo', '~> 2.0.6'
gem 'tzinfo-data', '~> 1.2023.3'

gem 'administrate', '~> 0.19.0'
gem 'administrate-field-enum', '~> 0.0.9'

gem 'pretender', '~> 0.5.0'

gem 'octokit', '~> 5.0'

gem 'stimulus-rails', '~> 1.2.2'

group :development, :test do
  gem 'rspec-rails', '~> 6.1'
  gem 'rspec_junit_formatter', '~> 0.6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'byebug', '~> 11.0', platforms: %i[mri mingw x64_mingw]
  gem 'pry-byebug', '~> 3.9'
  gem 'launchy', '~> 2.4', '>= 2.4.3'
  gem 'rails-controller-testing', '~> 1.0.5'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 3.1'
  gem 'listen', '~> 3.3'
  gem 'spring', '~> 4.1'
  gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'guard-rubocop', '~> 1.5.0'
  gem 'letter_opener', '~> 1.8.1'
  gem 'rails-erd', '~> 1.7.2'
  gem 'state_machines-graphviz', '~> 0.0.2'
  gem 'debug', '>= 1.0.0'
  gem 'solargraph', '~> 0.50.0'
  gem 'bullet', '~> 7.1.4'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'capybara-screenshot', '~> 1.0.26'
  gem 'selenium-webdriver', '~> 4.10.0'
  gem 'webdrivers', '~> 5.3.1'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'pundit-matchers', '~> 3.1.2'
  gem 'state_machines-rspec', '~> 0.6.0'
  gem 'webmock', '~> 3.19.1'
end

gem 'noticed', '~> 1.6'

gem 'abyme', '~> 0.7.0'

gem 'pg_search', '~> 2.3'
gem 'administrate-field-belongs_to_search', '~> 0.8.0'
gem 'faker', '~> 3.2.2'

# Use Redis for Action Cable
gem 'redis', '~> 5.0'

gem 'jsbundling-rails', '~> 1.2'

gem 'cssbundling-rails', '~> 1.3'

gem 'sprockets-rails', require: 'sprockets/railtie'
