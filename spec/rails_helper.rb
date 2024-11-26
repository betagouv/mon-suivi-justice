# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'pundit/matchers'
require 'webmock/rspec'
require 'sidekiq/testing'
require 'paper_trail/frameworks/rspec'
require "support/with_env"
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  config.include FactoryBot::Syntax::Methods
  config.include Warden::Test::Helpers
  config.include StateMachinesRspec::Matchers
  config.include ApplicationHelper

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    stub_request(:any, /api\.sendinblue\.com/)
    stub_request(:any, /europe\.ipx\.com/)
    stub_request(:any, /ingest\.sentry\.io\.*/)
  end

  config.after(:each) do
    FactoryBot.rewind_sequences
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :selenium_headless
Capybara.default_max_wait_time = 5
Capybara.default_normalize_ws = true
Capybara.asset_host = "http://localhost:3001"
Capybara.raise_server_errors = false
Capybara.enable_aria_label = true

Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.description.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end

Capybara::Screenshot.autosave_on_failure = true
Capybara.save_path = "./screenshots/"

Selenium::WebDriver.logger.ignore(:browser_options)

driver_urls = Webdrivers::Common.subclasses.map do |driver|
  Addressable::URI.parse(driver.base_url).host
end

driver_urls << "github-releases.githubusercontent.com"
driver_urls << "objects.githubusercontent.com"

WebMock.disable_net_connect!(allow_localhost: true, allow: [*driver_urls])

def create_admin_user_and_login
  @admin = create(:user, :in_organization, role: :admin)
  login_as(@admin, scope: :user)
  @admin
end

def create_cpip_user_and_login
  @cpip = create(:user, role: :cpip)
  login_as(@cpip)
  @cpip
end

def create_user_and_login(role, org_type, interressort: false, security_charter_accepted_at: Time.zone.now - 1.minute)
  @user = create(:user, :in_organization, type: org_type, role: role, interressort:, security_charter_accepted_at:)
  login_as(@user)
  @user
end

def logout_current_user
  logout(scope: :user)
end

def login_user(user)
  login_as(user, scope: :user)
end

def new_time_for(hour, min)
  timezone = TZInfo::Timezone.get('Europe/Paris')
  Time.new(2021, 6, 21, hour, min, 0, timezone)
end

def create_default_notification_types
  AppointmentType.all.each do |apt_type|
    NotificationType.roles.keys.each do |role|
      create(:notification_type, appointment_type: apt_type, role: role, organization: nil, is_default: true)
    end
  end
end

def create_appointment(convict = nil, organization = nil, appointment_type: nil, date: Time.zone.now, slot_capacity: 3)
  skip_validations = date.past?
  organization ||= create(:organization)
  convict ||= create(:convict, organizations: [organization])
  appointment_type ||= create(:appointment_type, :with_notification_types, organization:)
  place = create(:place, organization:, appointment_types: [appointment_type])
  agenda = create(:agenda, place:)

  slot = build(:slot, agenda:, date:, appointment_type:, capacity: slot_capacity)
  slot.save(validate: !skip_validations)
  appointment = build(:appointment, convict:, slot:)
  appointment.save(validate: !skip_validations)
  appointment
end

def generate_appi_uuid
  "2024#{Faker::Number.number(digits: 8)}"
end

def create_ignore_validation(*args)
  data = build(*args)
  data.save(validation: false)
  data
end
