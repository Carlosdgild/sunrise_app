# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'vendor'
  add_filter 'tmp'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
SimpleCov.minimum_coverage line: 90
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'database_cleaner'
# require 'pundit/matchers'
# require 'pundit/rspec'
# require 'paper_trail/frameworks/rspec'
# require 'pundit/matchers'

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
# include all support classes
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each do |f|
  require f
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# disable HTTP connections
WebMock.disable_net_connect!

# VCR config
VCR.configure do |config|
  is_runner = ENV.fetch('GITLAB_CI_RUNNER') { 'false' } == 'true'
  config.default_cassette_options.merge!(record: :none) if is_runner

  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

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

  # add FactoryBot methods
  config.include FactoryBot::Syntax::Methods
  # add Route helpers
  config.include Rails.application.routes.url_helpers
  # include RequestSpecHelper
  config.include RequestSpecHelper
  # Helpers
  config.include Requests::AuthHelpers::Includables, type: :request
  config.extend Requests::AuthHelpers::Extensions, type: :request

  # start by truncating all the tables but then use the faster transaction
  # strategy the rest of the time.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  # start the transaction strategy as examples are run
  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

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

  # global +BackgroundAltanRequestJob+ mock to disable async interactions
  # async examples can be tested with +:mock_async_altan+ bool modifier
  config.before do |_example|
    # remove retry support
    allow_any_instance_of(BackgroundAltanRequestJob).to receive(:retry_job)
  end

  # Bullet configuration
  if Bullet.enable?
    config.before do
      Bullet.start_request
    end

    config.after do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end

  # global mocks
  config.before do |example|
    skip_repep_gui = example.metadata[:skip_repep_gui]
    next unless skip_repep_gui

    allow_any_instance_of(Puppeteer::Puppeteer)
      .to receive(:launch) do |_args, &block|
      block.call
    end
  end

  config.after do |example|
    skip_repep_gui = example.metadata[:skip_repep_gui]
    next unless skip_repep_gui

    allow_any_instance_of(Puppeteer::Puppeteer)
      .to receive(:launch)
      .and_call_original
  end
end
