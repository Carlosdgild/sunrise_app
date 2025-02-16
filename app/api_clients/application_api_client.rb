# frozen_string_literal: true

#
# Main Application API Client class wrapper
# API Clients should perform some kind of error handling and return the data
# (if any) with the boolean indicating if an error occurred
#
class ApplicationApiClient
  class << self
    def get_req(url, headers = {})
      RestClient.get url, headers
    end

    # :reek:UtilityFunction
    def log_message(level = :info, message = '')
      Rails.logger.public_send(level, message)
    end
  end
end
