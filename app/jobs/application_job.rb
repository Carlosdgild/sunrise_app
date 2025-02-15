# frozen_string_literal: true

# Main Application Job class wrapper
#
class ApplicationJob < ActiveJob::Base
  # include Sidekiq::Worker

  # sidekiq_options queue: :mailers
  # sidekiq_throttle_as :xyz_api

  #
  # Main perform method to be overriden
  #
  def perform
    raise 'Not implemented'
  end
end
