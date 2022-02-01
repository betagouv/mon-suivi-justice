Sentry.init do |config|
  config.enabled_environments = %w[production]
  config.environment = ENV["APP"] == "mon-suivi-justice-public" ? "production" : "staging"
  config.dsn = 'https://cf404ea82f3c4e46b1a7e736a8627180@o548798.ingest.sentry.io/5923458'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |context|
    true
  end

  config.excluded_exceptions -= ['ActionController::RoutingError']
end
