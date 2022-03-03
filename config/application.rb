require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MonSuiviJustice
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.generators do |g|
      g.test_framework :rspec
    end

    config.i18n.default_locale = :fr

    config.active_job.queue_adapter = :sidekiq
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Paris"
    config.active_record.default_timezone = :local

    # config.eager_load_paths << Rails.root.join("extras")
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Permet d'utiliser NGROK en local
    # config.hosts << "52fa-193-248-45-184.ngrok.io"

    config.i18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml}"]

    config.exceptions_app = routes
  end
end
