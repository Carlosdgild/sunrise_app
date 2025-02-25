# frozen_string_literal: true

# RetrieveLocationInformationService
class RetrieveLocationInformationService < ApplicationService
  IMPORTANT_KEYS = %i[information_date sunrise sunset golden_hour].freeze
  KEY_MAPPING = {
    information_date: 'date',
    sunrise: 'sunrise',
    sunset: 'sunset',
    golden_hour: 'golden_hour'
  }.freeze

  attr_accessor :location_name, :longitude, :latitude, :location, :start_date, :end_date,
                :diff_between_date

  def call!
    return @location_informations if validate_day_quantity

    results = SunriseSunsetApiClient.fetch_information_for_location(
      location.latitude, location.longitude, start_date, end_date
    )
    if results.last.key?(:error)
      raise CustomStandardError.new('An error has occured while getting information')
    end

    CreateLocationInformationJob.perform_later(location.id, results, start_date, end_date)
    serialize_results(results)
  end

  private

  def initialize(location_name, latitude, longitude, start_date, end_date)
    @location_name = location_name
    @latitude = latitude
    @longitude = longitude
    @start_date = start_date
    @end_date = end_date
    validate_required_params!
    validate_dates!
    @location = find_or_create_location!
    @location_informations = fetch_location_information
  end

  # Finds or create location acording to the given location_name
  # @returns ActiveRecord::Relation
  def find_or_create_location!
    Location.find_by!(name: location_name)
  rescue ActiveRecord::RecordNotFound
    Location.create_new_location!(
      location_name,
      latitude,
      longitude
    )
  end

  # Retrieves LocationInformation records filtered by location_id and the given dates
  # @returns ActiveRecord::Relation
  def fetch_location_information
    LocationInformation.filter_by_start_and_end_date(location.id, start_date, end_date)
  end

  # Creates an array with important keys to serialize when the response is from
  # an external API
  # @returns Array
  def serialize_results(results)
    results.map do |day|
      IMPORTANT_KEYS.index_with do |key|
        day[KEY_MAPPING[key]]
      end
    end
  end

  # Validates if the found location information records are the same quantity
  # that is requested
  # @returns Boolean
  def validate_day_quantity
    @location_informations.count == @diff_between_date
  end

  def validate_required_params!
    return unless @location_name.blank? || @start_date.blank? || @end_date.blank?

    raise CustomStandardError.new('Location name, start date and end date, can not be null')
  end

  def validate_dates!
    start_date = Date.parse(@start_date)
    end_date = Date.parse(@end_date)
    @diff_between_date = (end_date - start_date).to_i + 1
    return if diff_between_date <= 365 && diff_between_date >= 0

    raise CustomStandardError.new('Invalid dates')
  end
end
