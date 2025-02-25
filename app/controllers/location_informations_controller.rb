# frozen_string_literal: true

# LocationInformationsController
class LocationInformationsController < ApplicationController
  before_action :information_range_params, only: %i[information_range]
  before_action :format_dates, only: %i[information_range]
  before_action :validate_dates!, only: %i[information_range]

  # Endpoint without authentication to retrieve data from a place within dates
  # @example
  # [{"information_date"=>"2024-01-01", "sunrise"=>"7:55:35 AM",
  #   "sunset"=>"5:25:21 PM", "golden_hour"=>"4:43:40 PM"},
  #  {"information_date"=>"2024-01-02", "sunrise"=>"7:55:46 AM",
  #   "sunset"=>"5:26:06 PM", "golden_hour"=>"4:44:28 PM"},
  #  {"information_date"=>"2024-01-03", "sunrise"=>"7:55:54 AM",
  #   "sunset"=>"5:26:53 PM", "golden_hour"=>"4:45:19 PM"},
  #  {"information_date"=>"2024-01-04", "sunrise"=>"7:56:00 AM",
  #   "sunset"=>"5:27:42 PM", "golden_hour"=>"4:46:11 PM"}]
  def information_range
    results = RetrieveLocationInformationService.call!(
      @location_name, @latitude, @longitude, @start_date, @end_date
    )
    render json: results
  end

  private

  # Method that retrieves and checks for the required params
  # @returns nil
  def information_range_params
    @location_name = params.require(:location_name)
    @latitude = params.permit(:latitude)[:latitude]
    @longitude = params.permit(:longitude)[:longitude]
    @start_date = params.require(:start_date)
    @end_date = params.require(:end_date)
  end

  # Format the given dates to YYYY-mm-dd format
  # @returns nil
  def format_dates
    yyyy_mm_dd_pattern = /^\d{4}-\d{2}-\d{2}$/

    @start_date = format_date(@start_date, yyyy_mm_dd_pattern)
    @end_date = format_date(@end_date, yyyy_mm_dd_pattern)
  end

  # Formats the given date to YYYY-mm-dd format
  # @returns Date
  # @raises ActionController::BadRequest
  def format_date(date, pattern)
    return date if date.match?(pattern)

    begin
      Date.parse(date).strftime('%Y-%m-%d')
    rescue ArgumentError
      raise ActionController::BadRequest.new('Invalid date format')
    end
  end

  # Validates if end_date is after start_date, and the diff between them is
  # lesser than 365 days
  # @returns nil
  # @raises ArgumentError
  def validate_dates!
    start_date = Date.parse(@start_date)
    end_date = Date.parse(@end_date)
    return if end_date >= start_date && (end_date - start_date).to_i <= 365

    raise ArgumentError.new('Dates are wrong or selected more than a year between them')
  end
end
