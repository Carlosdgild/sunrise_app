# frozen_string_literal: true

# Coordinate API Client
class CoordinateApiClient < ApplicationApiClient
  class << self
    attr_reader :response, :error

    def fetch_coordinates(name)
      coordinates = fetch_coordinates_for_location(name)
      return [nil, error] if error

      coordinates
    end

    private

    def fetch_coordinates_for_location(name)
      log_message(:info, "Getting coordinates for '#{name}'")

      @response = get_req(
        "https://nominatim.openstreetmap.org/search?q=#{name}&format=json",
        { content_type: :json, accept: :json }
      )
      if response.code != 200
        log_message(:error, "Could not get coordinates for #{name}")
        @error = 'Could not fetch coordinates'
        return
      end

      begin
        parsed_data = JSON.parse(@response)
        first_location = parsed_data.first
        latitude = first_location['lat']
        longitude = first_location['lon']
      rescue NoMethodError => e
        log_message(:error, "No coordinates for that location. #{e.message}")
        @error = 'No coordinates for that location'
      rescue StandardError => e
        log_message(:error, "Error trying to get lat or long. #{e.message}")
        @error = 'Could not fetch coordinates'
        return
      end
      { latitude: latitude, longitude: longitude }
    end
  end
end
