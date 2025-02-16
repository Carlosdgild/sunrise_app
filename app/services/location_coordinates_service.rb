# frozen_string_literal: true

# LocationCoordinatesService
class LocationCoordinatesService < ApplicationService
  attr_accessor :location_name

  def call!
    coordinates, error = CoordinateApiClient.fetch_coordinates(location_name)
    if error
      raise CustomStandardError.new(
        'An error has occured while getting coordinates for the location'
      )
    end

    Location.create_location_record_with_coordinates!(
      location_name, coordinates[:latitude], coordinates[:longitude]
    )
  end

  private

  def initialize(location_name)
    @location_name = location_name
  end
end
