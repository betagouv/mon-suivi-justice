source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'
gem 'rails', '~> 6.1.3', '>= 6.1.3.2'

gem 'pg'
gem 'puma', '~> 5.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'net-http' # here to silence a warning, to remove

gem 'bootsnap', '>= 1.4.4', require: false

gem 'devise'
gem 'pundit'
gem 'simple_form'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'launchy', '~> 2.4', '>= 2.4.3'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'guard-rspec', require: false
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'pundit-matchers', '~> 1.6.0'
end
