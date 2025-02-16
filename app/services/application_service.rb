# frozen_string_literal: true

# ApplicationService Definition
class ApplicationService
  # static service implementation
  # should raise any exception
  def self.call!(*args, &block)
    new(*args).call!(&block)
  end
end
