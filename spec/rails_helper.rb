# This file is copied to spec/ when you run 'rails generate rspec:install'
# require 'spec_helper'

# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'vendor'
  add_filter 'tmp'
end
ENV['RAILS_ENV'] ||= 'test'
SimpleCov.minimum_coverage line: 90
require File.expand_path('../config/environment', __dir__)
require_relative '../config/environment'
require 'database_cleaner'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

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
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# disable HTTP connections
WebMock.disable_net_connect!

# VCR config
VCR.configure do |config|
  is_runner = ENV.fetch('GITLAB_CI_RUNNER', 'false') == 'true'
  config.default_cassette_options.merge!(record: :none) if is_runner

  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock

  # openstreetmap
  config.register_request_matcher :openstreetmap do |real_request, recorded_request|
    url_regex = /^https:\/\/nominatim\.openstreetmap\.org\/search\?q=.*&format=json$/
    result = (real_request.uri == recorded_request.uri) ||
             (
               url_regex.match(real_request.uri) &&
               url_regex.match(recorded_request.uri)
             )
    result
  end

  # sunrisesunset
  config.register_request_matcher :sunrisesunset do |real_request, recorded_request|
    url_regex = /^https:\/\/api\.sunrisesunset\.io\/json\?lat=[\d.-]+&lng=[\d.-]+&date_start=\d{4}-\d{2}-\d{2}&date_end=\d{4}-\d{2}-\d{2}$/
    result = (real_request.uri == recorded_request.uri) ||
             (
               url_regex.match(real_request.uri) &&
               url_regex.match(recorded_request.uri)
             )
    result
  end
end

RSpec.configure do |config|
  # rails 6 requires to explicitly set job queue
  config.before :example, :perform_enqueued do
    @old_perform_enqueued_jobs =
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs
    @old_perform_enqueued_at_jobs =
      ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
  end

  # Return the Job Queue to his initial state
  config.after :example, :perform_enqueued do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs =
      @old_perform_enqueued_jobs
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs =
      @old_perform_enqueued_at_jobs
  end
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/7-1/rspec-rails
  #
  # You can also this infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  # config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # add FactoryBot methods
  config.include FactoryBot::Syntax::Methods
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  # include RequestSpecHelper
  config.include RequestSpecHelper
  Shoulda::Matchers.configure do |configu|
    configu.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.include ActiveJob::TestHelper
  config.before(:each, type: :job) do
    ActiveJob::Base.queue_adapter = :test
  end
end
