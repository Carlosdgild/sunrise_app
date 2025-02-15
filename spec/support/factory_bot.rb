# frozen_string_literal: true

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # FactoryBot sequences are global, meaning that they don’t reset by default between each
  # and every test; a FactoryBot instance during one test run might use a different sequence
  # number than a previous test run.
  # Therefore, it’s also necessary to rewind FactoryBot sequences after each RSpec example
  config.after do
    FactoryBot.rewind_sequences
  end
end
