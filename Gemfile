source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'
gem 'rails', '~> 7.0.0', '>= 7.0.8'

gem 'pg', '~> 1.3'
gem 'puma', '~> 5.6'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'turbo-rails', '~> 1.5'

gem 'devise', '~> 4.9'
gem 'devise-i18n', '~> 1.12'
gem 'devise_invitable', '~> 2.0.0'
gem 'devise-security', '>= 0.18.0'

gem 'pundit', '~> 2.1'
gem 'simple_form', '~> 5.1'
gem 'addressable', '~> 2.8' # fix scalingo deploy bug
gem 'cocoon', '~> 1.2'

gem 'phony_rails', '~> 0.15'

gem 'ransack', '~>4.1'
gem 'kaminari', '~> 1.2'
gem 'font-awesome-sass', '~> 6.1'

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
gem 'sentry-ruby', '~> 5.14'
gem 'sentry-rails', '~> 5.14'
gem 'ruby-progressbar', '~> 1.11'

gem 'jbuilder', '~> 2.11', '>= 2.11.5'
gem 'groupdate', '~> 6.4'

gem 'faraday', '~> 2.7'
gem 'faraday-retry', '~> 2.2'

gem 'wicked_pdf', '~> 2.6'
gem 'wkhtmltopdf-binary', '~> 0.12'

gem 'tzinfo'
gem 'tzinfo-data'

gem 'administrate'
gem 'administrate-field-enum'

gem 'pretender'

gem 'octokit', '~> 5.0'

gem 'stimulus-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'factory_bot_rails'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-byebug', '~> 3.9'
  gem 'launchy', '~> 2.4', '>= 2.4.3'
  gem 'rails-controller-testing'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 3.1'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  gem 'letter_opener'
  gem 'rails-erd'
  gem 'state_machines-graphviz'
  gem 'debug', '>= 1.0.0'
  gem 'solargraph'
  gem 'bullet'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'state_machines-rspec'
  gem 'webmock'
end

gem 'noticed', '~> 1.6'

gem 'abyme', '~> 0.7.0'

gem 'pg_search', '~> 2.3'
gem 'administrate-field-belongs_to_search'
gem 'faker'

# Use Redis for Action Cable
gem 'redis', '~> 4.0'

gem 'jsbundling-rails', '~> 1.1'

gem 'cssbundling-rails', '~> 1.3'

gem 'sprockets-rails', require: 'sprockets/railtie'
