# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :location_informations, dependent: :nullify

  # Validations
  validates :name, :latitude, :longitude, presence: true
  validates :name, uniqueness: true
end
