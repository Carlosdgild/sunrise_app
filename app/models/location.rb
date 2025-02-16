# frozen_string_literal: true

# Location model
class Location < ApplicationRecord
  has_many :location_informations, dependent: :nullify

  # Validations
  validates :name, :latitude, :longitude, presence: true
  validates :name, uniqueness: true

  # Verifies it has the parameters to create a new instance or have to call a
  # service to make a request for the coordinates
  # @returns Location
  # @raise ActiveRecord::Error
  def self.create_new_location!(location_name, latitude, longitude)
    if latitude.blank? || longitude.blank?
      LocationCoordinatesService.call!(location_name)
    else
      create_location_record_with_coordinates!(location_name, latitude, longitude)
    end
  end

  # Creates a new location
  # @returns Location
  # @raise ActiveRecord::Error
  def self.create_location_record_with_coordinates!(name, latitude, longitude)
    if latitude.nil? || longitude.nil?
      raise ArgumentError.new('Latitude and longitude cannot be nil')
    end

    create!(name: name, latitude: latitude.to_f, longitude: longitude.to_f)
  end
end
