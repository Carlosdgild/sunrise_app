# frozen_string_literal: true

# CreateLocationInformationJob
class CreateLocationInformationJob < ApplicationJob
  queue_as :default

  def perform(location_id, results, start_date = nil, end_date = nil)
    Location.find(location_id)
    query = LocationInformation.where(location_id: location_id)
    query = query.where(information_date: start_date..end_date) if start_date && end_date
    existing_dates = query.pluck(:information_date).to_set

    results.each do |result|
      next if existing_dates.include?(result['date'].to_date)

      begin
        LocationInformation.create!(
          location_id: location_id,
          information_date: result['date'],
          sunrise: result['sunrise'],
          sunset: result['sunset'],
          first_light: result['first_light'],
          last_light: result['last_light'],
          dawn: result['dawn'],
          dusk: result['dusk'],
          solar_noon: result['solar_noon'],
          golden_hour: result['golden_hour'],
          day_length: result['day_length']
        )
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error(
          "Failed to create LocationInformation for date #{result['date']}: #{e.message}"
        )
      rescue StandardError => e
        Rails.logger.error "Unexpected error while creating LocationInformation: #{e.message}"
      end
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Location with ID #{location_id} not found. Job failed."
  rescue StandardError => e
    Rails.logger.error "Unexpected error in job: #{e.message}"
  end
end
