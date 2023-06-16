Sentry.init do |config|
  config.enabled_environments = %w[staging production review]
  config.dsn = ENV["SENTRY_DNS"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  if ENV['APP'] == 'mon-suivi-justice-staging'
    config.environment = 'staging'
  elsif ENV['APP'] == 'mon-suivi-justice-prod'
    config.environment = 'production'

  elsif ENV['APP']&.match?(/^mon-suivi-justice-staging-pr\d+/)
    config.environment = 'review'
  end

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.02
end
