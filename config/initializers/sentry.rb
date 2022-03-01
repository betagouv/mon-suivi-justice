Sentry.init do |config|
  config.enabled_environments = %w[production]
  config.dsn = ENV["SENTRY_DNS"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.02
end
