# frozen_string_literal: true

# RetrieveLocationInformationService
class RetrieveLocationInformationService < ApplicationService
  IMPORTANT_KEYS = %i[date sunrise sunset golden_hour].freeze

  attr_accessor :location_name, :longitude, :latitude, :location, :start_date, :end_date

  def call!
    return @location_informations if @location_informations.present?

    results = SunriseSunsetApiClient.fetch_information_for_location(
      location.latitude, location.longitude, start_date, end_date
    )
    if results.last.key?(:error)
      raise CustomStandardError.new('An error has occured while getting information')
    end

    CreateLocationInformationJob.perform_later(location.id, results)
    serialize_results(results)
  end

  private

  def initialize(location_name, latitude, longitude, start_date, end_date)
    @location_name = location_name
    @latitude = latitude
    @longitude = longitude
    @start_date = start_date
    @end_date = end_date
    @location = find_or_create_location!
    @location_informations = fetch_location_information
  end

  def find_or_create_location!
    Location.find_by!(name: location_name)
  rescue ActiveRecord::RecordNotFound
    Location.create_new_location!(
      location_name,
      latitude[:latitude],
      longitude[:longitude]
    )
  end

  def fetch_location_information
    LocationInformation.filter_by_start_and_end_date(location.id, start_date, end_date)
  end

  def serialize_results(results)
    results.map do |day|
      {
        information_date: day['date'],
        sunrise: day['sunrise'],
        sunset: day['sunset'],
        golden_hour: day['golden_hour']
      }
    end
  end
end
