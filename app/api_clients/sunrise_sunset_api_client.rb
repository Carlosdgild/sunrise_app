# frozen_string_literal: true

# SunriseSunsetApiClient
class SunriseSunsetApiClient < ApplicationApiClient
  class << self
    attr_reader :response, :error

    def fetch_information_for_location(lat, lon, start_date, end_date)
      result = fetch_information(lat, lon, start_date, end_date)
      return result << { error: error } if error

      result
    end

    private

    def fetch_information(lat, lon, start_date, end_date)
      log_message(:info, "Getting information for #{lat} and #{lon}")

      @response = get_req(
        "https://api.sunrisesunset.io/json?lat=#{lat}&lng=#{lon}&date_start=#{start_date}&date_end=#{end_date}",
        { content_type: :json, accept: :json }
      )

      if response.code != 200
        log_message(:error, "information for #{lat} and #{lon}")
        @error = 'Could not fetch information'
        return
      end

      begin
        parsed_data = JSON.parse(@response)['results']
      rescue StandardError => e
        log_message(:error, "Error trying to get lat or long. #{e.message}")
        @error = 'Could not fetch coordinates'
        return
      end
      parsed_data
    end
  end
end
