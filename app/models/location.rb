# frozen_string_literal: true

# Location model
class Location < ApplicationRecord
  has_many :location_informations, dependent: :nullify

  # Validations
  validates :name, :latitude, :longitude, presence: true
  validates :name, uniqueness: true

  def self.create_new_location!(location_name, latitude, longitude)
    if latitude.blank? || longitude.blank?
      LocationCoordinatesService.call!(location_name)
    else
      create_location_record(location_name, latitude, longitude)
    end
  end

  def self.create_location_record(name, latitude, longitude)
    create!(name: name, latitude: latitude.to_f, longitude: longitude.to_f)
  end
end
