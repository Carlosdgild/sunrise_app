# frozen_string_literal: true

class LocationInformation < ApplicationRecord
  belongs_to :location

  # Validations
  validates :start_date, :end_date, presence: true
end
