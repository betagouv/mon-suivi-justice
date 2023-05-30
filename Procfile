web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq
clock: bundle exec clockwork config/clock.rb
postdeploy: bundle exec rake db:migrate