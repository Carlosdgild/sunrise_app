# frozen_string_literal: true

class LocationInformation < ApplicationRecord
  belongs_to :location

  # Validations
  validates :information_date, presence: true

  # returns an Active:Record relation of the collection filtered by
  # +location_id+, +start_date+ and +end_date+ params.
  # @param [Integer] - location_id
  # @param [Date] - start_date - %d-%m-%Y
  # @param [Date] - end_date - %d-%m-%Y
  # @return [ActiveRecord::Relation]
  def self.filter_by_start_and_end_date(location_id, start_date, end_date)
    where(location_id: location_id, information_date: start_date..end_date)
  end
end
