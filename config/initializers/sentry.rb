Sentry.init do |config|
  config.dsn = 'https://4ef78cbaefdf47f2b5050d07fc9a8005@o962600.ingest.sentry.io/5910915'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end
