# frozen_string_literal: true

# LocationInformationsController
class LocationInformationsController < ApplicationController
  before_action :information_range_params, only: %i[information_range]
  before_action :format_dates, only: %i[information_range]
  before_action :validate_dates!, only: %i[information_range]
  # Endpoint without authentication to retrieve data from a place within dates
  # @example
  def information_range
    results = RetrieveLocationInformationService.call!(
      @location_name, @latitude, @longitude, @start_date, @end_date
    )
    # if results.is_a?(Hash)
    render json: results
    # else
    # render json: results, each_serializer: LocationInformationSerializer
    # end
  end

  private

  # Method that retrieves and checks for the required params
  def information_range_params
    @location_name = params.require(:location_name)
    @latitude = params.permit(:latitude)
    @longitude = params.permit(:longitude)
    @start_date = params.require(:start_date)
    @end_date = params.require(:end_date)
  end

  def format_dates
    yyyy_mm_dd_pattern = /^\d{4}-\d{2}-\d{2}$/
    return if @start_date.match?(yyyy_mm_dd_pattern) && @end_date.match?(yyyy_mm_dd_pattern)

    @start_date = Date.strptime(@start_date, '%d-%m-%Y').strftime('%Y-%m-%d')
    @end_date = Date.strptime(@end_date, '%d-%m-%Y').strftime('%Y-%m-%d')
  end

  def validate_dates!
    start_date = Date.parse(@start_date)
    end_date = Date.parse(@end_date)
    return if end_date > start_date && (end_date - start_date).to_i <= 365

    raise ArgumentError.new('Dates are wrong')
  end
end
